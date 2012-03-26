class Doc::DocumentsController < ApplicationController
  before_filter :non_public_role_required
  before_filter :can_edit_document, :only => [:edit, :move, :destroy]
  
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def show
    @document = Document.find(params[:id]).viewable_by(current_user)

    DocumentMailer.document_viewed(@document, current_user).deliver if @document.folder && @document.folder.notify_of_file_download && @document.owner != current_user

    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment', :x_sendfile => request.env["SERVER_SOFTWARE"].downcase.match(/apache/) ? true : false
  end

  def create
    begin
      params[:folder_id] = nil if params[:folder_id] == 'null' || params[:folder_id] == '' || params[:folder_id] == '0'

      @parent_folder = params[:folder_id] ?  Folder.find(params[:folder_id].to_i) : nil

      #check to make sure the user can write to this folder here
      unless @parent_folder.nil? || @parent_folder.author?(current_user)
        respond_to do |format|
          format.json { render :json => {:success => false, :msg => "Current user does not have permission to create this file."}, :content_type => 'text/html', :status => 401 }
        end
        return
      end
      
      unless (@parent_folder ? @parent_folder.documents : current_user.documents.inbox).detect{|x| x.file_file_name == URI.decode(params[:file].original_filename)}
        @document = (@parent_folder && @parent_folder.owner ? @parent_folder.owner.documents : current_user.documents).build(:file => params[:file], :folder => @parent_folder)
        @document.owner_id = current_user.id
        if @document.valid?
          @document.save!

          #file creation was successful, let's notify users that a file was uploaded
          DocumentMailer.document_addition(@document, current_user).deliver if !@document.folder.nil? && @document.folder.notify_of_document_addition
          respond_to do |format|
            format.json {render :json => {:success => true }, :content_type => 'text/html' }
          end
        else
          respond_to do |format|
            format.json {render :json => {:msg => @document.errors["file"].as_json, :success => false }, :content_type => 'text/html', :status => 400 }
          end
          return
        end
      else
        respond_to do |format|
          format.json {render :json => {:msg => 'File name is already in use. Try renaming the file.', :success => false }, :content_type => 'text/html', :status => 409 }
        end
        return
      end
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:msg => 'An error occurred while saving the document. An administrator has been notified.', :error => e.to_s, :backtrace => e.backtrace, :success => false }, :content_type => 'text/html', :status => 409 }
      end
    end
  end

  def edit
    @document = Document.find(params[:id]).editable_by(current_user)
  end

  def update
    begin
      @document = Document.find(params[:id]).editable_by(current_user)
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:msg => 'Could not find the document specified.', :error => e.to_s, :backtrace => e.backtrace, :success => false }, :content_type => 'text/html', :status => 409 }
      end
      return
    end

    respond_to do |format|
      if !@document
        # render that the user was unable to edit the document
        format.json {render :json => { :msg => 'You do not have permission to change this document.', :success => false }, :content_type => 'text/html', :status => 401 }
        return
      end

      if (@document.folder ? @document.folder.documents : current_user.documents.inbox).detect {|x| x != @document && params[:document][:file] && x.file_file_name == params[:document][:file].original_filename }
        # render that the user needs to select a different file because this already exists
        format.json {render :json => {:msg => 'A file with this name already exists in the folder, please select a file with a unique name.', :success => false }, :content_type => 'text/html', :status => 400 }
      end

      if @document.update_attributes(params[:document])
         DocumentMailer.document_update(@document, current_user).deliver if @document.folder && @document.folder.notify_of_document_addition

         format.json {render :json => {:success => true}, :content_type => 'text/html' }
      else
        #render that there was some sort of error
        format.json {render :json => { :success => false, :msg => "An unknown error occurred", :errors => @document.errors }, :status => 400, :content_type => 'text/html' }
      end
    end
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      respond_to do |format|
        format.json { render :json => {:success => true } }
      end
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => "An unknown error occurred", :errors => @document.errors }, :status => 400 }
      end
    end
  end

  def move
    document = Document.find(params[:id])

    params[:parent_id] = nil if params[:parent_id] == 'null' || params[:parent_id] == ''

    document.folder_id = params[:parent_id]

    if document.save!
      respond_to do |format|
        format.json { render :json => {:success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => {:success => false, :errors => document.errors }, :status => 400 }
      end
    end
  end

  def copy
    document = Document.find(params[:id])
    folder = params[:parent_id].blank? ? nil : Folder.find(params[:parent_id])

    unless document.audience.recipients.include?(current_user)
      respond_to do |format|
        format.json { render :json => { :msg => 'Current user does not have permission to modify this document.', :success => false}, :status => 401}
      end
      return
    end
    
    document.copy(current_user, folder)

    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end

  def can_edit_document
    document = Document.find(params[:id])
    unless document.editable_by?(current_user)
      respond_to do |format|
        format.json { render :json => { :msg => 'Current user does not have permission to modify this document.', :success => false}, :status => 401}
      end
      false
    end
  end

  def search
    results = []
    results << Document.search(params[:text], :star => true, :with => {:owner_id => current_user.id }).to_a if (params[:own] == 'true')
    results << Document.search(params[:text], :star => true, :with => {:shared_with_ids => current_user.id }, :without => {:owner_id => current_user.id }).to_a if (params[:shared] == 'true')
    results.flatten!.sort! {|x, y| x[:file_file_name] <=> y[:file_file_name] }

    respond_to do |format|
      format.json {render :json => {:files => results.map do |result|
            result[:is_author] = result.editable_by?(current_user)
            result[:is_owner] = result.owner_id == current_user.id
            result[:doc_url] = document_path(result)
            result.as_json(:include => {:owner => {:only => [:display_name]}} )
        end 
      } }
    end
  end
  
  def recent_documents
    @documents = current_user.shared_documents.limit(params[:num_documents].blank? ? 5 : params[:num_documents].to_i)
    
    respond_to do |format|
      format.json {
        render :json => @documents.map { 
          |doc| doc.as_json(:only => [:name, :created_at], 
                            :include => {:folder => {:only => [:name, :id]}, 
                            :owner => {:only => [:id, :display_name]}
                          }).merge({:url => document_path(doc)})
        }
      }
    end
  end
end
