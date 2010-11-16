class DocumentsController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back

  layout "documents", :except => [:show, :popup_documents]
  layout "application", :only => :popup_documents

  def panel_index
    set_panel_defaults
  end

  def media_list
    set_panel_defaults
  end

  def index
    if params[:share_id]
      begin
        @share   = (current_user.shares | current_user.owned_shares).find {|share| share.id.to_s == params[:share_id]}
        @name      = @share.name
        @documents = [@share.documents].flatten
      rescue
        flash[:error] = "share does not exist"
        redirect_to documents_panel_path
      end
    elsif params[:folder_id]
      begin
        @parent_folder = current_user.folders.find(params[:folder_id])
        @name          = @parent_folder.name
        @folder        = Folder.new
        @documents     = [@parent_folder.documents].flatten  
      rescue
        flash[:error] = "Folder does not exist"
        redirect_to documents_panel_path
      end
    else
      flash[:error] = "No share or Folder provided"
      redirect_to documents_panel_path
    end
  end
  
  def create
    @parent_folder = current_user.folders.find(params[:document][:folder_id].to_i) || Folder.new
    unless @parent_folder.documents.detect{|x| x.file_file_name == params[:document][:file].original_filename}
      @document = current_user.documents.build(params[:document])
      @document.owner_id = current_user.id
      if @document.valid? 
        @document.save!
      else
       flash[:error] =  @document.errors["file"]
      end
    else
      flash[:error] = 'File name is already in use. Try renaming the file.'
      @document = current_user.documents.build(params[:document])
    end
    redirect_to folder_or_inbox_path(@document)
  end
  
  def show
    @document = Document.find(params[:id]).viewable_by(current_user)
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
  
  def edit
    @document = Document.find(params[:id]).editable_by(current_user)
  end
  
  def update
    @document = Document.find(params[:id]).editable_by(current_user)
    begin
      if @document.update_attributes(params[:document])
        #if user is not the original owner of the file, then find share where user has access to the file
        if @document.user_id != current_user.id
          (current_user.shares | current_user.owned_shares).each do |ch|
            ch.documents.each do |doc|
              if doc.id == @document.id
                redirect_to share_documents_path(ch)
              end
            end
          end
        else
          redirect_to folder_or_inbox_path(@document)
        end
      else
        render :edit
      end
    rescue ActiveRecord::StaleObjectError
      @document.reload
      #At this point we were originally returning embedded JavaScript in the flash[:error] variable, which is included in the response.
      #This was interfering with our capybara tests being able to properly identify the alert box as part of the current DOM since this alert
      #was being sent back with a whole new DOM. Remedied the situation by identifying the environment as test or cucumber and including the
      #JavaScript that Capybara needs to confirm and override the alert message
      if Rails.env == "test" || Rails.env == "cucumber"
        flash[:error] = "<script>parent.alert('Another user recently updated the document you are attempting to update to #{@document.file_file_name}.  Please try again.');</script>"            
      else
        flash[:error] = "<script>alert('Another user recently updated the document you are attempting to update to #{@document.file_file_name}.  Please try again.');</script>"
      end
      redirect_to folder_or_inbox_path(@document)
    rescue StandardError
      render :edit
    end
  end

  def destroy
    @document = Document.find(params[:id]).editable_by(current_user)
    @document.destroy
    flash[:notice] = "Successfully deleted the document from the inbox."
    redirect_to folder_inbox_path
  end

  def inbox
    @name = "Inbox"
    @documents = current_user.documents.inbox
    render "index"
  end
  
  def copy
    @document = Document.find(params[:id]).viewable_by(current_user)
  end
  
  def remove_from_share
    @document = Document.find(params[:id]).editable_by(current_user)
    @share = Share.find(params[:share_id])
    @share.documents.delete(@document)
    redirect_to share_documents_path(@share)
  end
  
  def remove_from_folder
    @document = Document.find(params[:id]).editable_by(current_user)
    @folder = current_user.folders.find(params[:folder_id])
    @folder.documents.delete(@document)
    @document.destroy
    flash[:notice] = "Successfully removed the document from the folder."
    redirect_to folder_or_inbox_path(@document)
  end

  def popup_documents
    
  end

  def mock_folder_list
    owned_shares = current_user.owned_shares
    user_shares = current_user.shares
    render :json => {:folders => ( [{:name => "My Documents", :id => nil, :safe_id => 0, :parent_id => nil, :leaf => false, :ftype => 'folder', :is_owner => true}] +
                                  current_user.folders.map { |folder| folder[:parent_id] = (folder[:parent_id].nil? ? 0 : 'folder' + folder[:parent_id].to_s ); folder[:safe_id] = 'folder' + folder[:id].to_s; folder[:leaf] = folder.leaf?; folder[:ftype] = 'folder'; folder[:is_owner] = true; folder.as_json} +
                                  [{:name => "My Shares", :id => -1, :safe_id => -1, :parent_id => nil, :leaf => owned_shares.length == 0, :ftype => 'mshare'} ] +
                                  owned_shares.map { |share| share[:parent_id] = -1; share[:safe_id] = 'mshare' + share[:id].to_s; share[:leaf] = true; share[:ftype] = 'mshare'; share.as_json } +
                                  [{:name => "Other's Shares", :id => -2, :safe_id => -2, :parent_id => nil, :leaf => user_shares.length == 0, :ftype => 'oshare' } ] +
                                  user_shares.map { |share| share[:parent_id] = -2; share[:safe_id] = 'oshare' + share[:id].to_s; share[:leaf] = true; share[:ftype] = 'mshare'; share.as_json }
                    ).as_json }
  end

  def mock_file_list

    if params[:type] == 'folder'
      folder = nil
      folder = Folder.find(params[:folder_id]) unless params[:folder_id].nil? || params[:folder_id] == 'null'
      docs = folder.nil? ? current_user.documents.inbox : folder.documents
      folders = folder.nil? ? current_user.folders.rootsm : folder.children
      docs.each {|doc| doc[:doc_url] = document_url(doc); doc[:ftype] = doc.file_content_type; doc[:name] = doc.file_file_name }
      folders.each { |f| f[:ftype] = 'folder' }
      render :json => { :files => folders.as_json | docs.as_json }
    elsif params[:type] == 'mshare'
    elsif params[:type] == 'oshare'
    else
        render :json => {:files => [] }
    end
    #render :json => {:files => [
    #  {:name => 'File 1', :id => 1, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 2', :id => 2, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 3', :id => 3, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 4', :id => 4, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 5', :id => 5, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 6', :id => 6, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 7', :id => 7, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #  {:name => 'File 8', :id => 8, :user => {:id => 15, :display_name => "User Name"}, :type => "text/doc", :size => '151 kb' },
    #]}
  end

  private
  def set_panel_defaults
    @folders = [current_user.folders.roots].flatten
    @folder = Folder.new
    @parent_folder = Folder.new
    @shares = (current_user.shares | current_user.owned_shares) - current_user.opt_out_shares
    current_folder = current_user.folders.find(params[:id]) unless params[:id].blank?
    current_share = current_user.shares.find(params[:share]) unless params[:share].blank?
    if current_folder
      @name = current_folder.name
      @documents = current_folder.documents
    elsif current_share
      @name = current_share.name
      @documents = current_share.documents
    else
      @name = "Inbox"
      @documents = current_user.documents.inbox
    end
  end
  
end
