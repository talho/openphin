class Doc::FoldersController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  before_filter :can_edit_folder, :only => [:edit, :update, :move, :destroy]
  after_filter :change_include_root_back

  def index
    folders = Folder.get_formatted_folders(current_user)

    shares = Folder.get_formatted_shares(current_user)

    render :json => {:folders => ( folders + shares ).as_json }
  end

  def show
    folder = params[:id].nil? || params[:id] == 'null' ? nil : Folder.find(params[:id])
    if !folder.nil? && !(folder.owner == current_user || folder.users.include?(current_user))
      render :json => { :files => [] }
      return
    end

    docs = folder.nil? ? current_user.documents.inbox : folder.documents
    folders = folder.nil? ? current_user.folders.rootsm : folder.children
    docs.each {|doc| doc[:doc_url] = document_url(doc) }
    folders.reject! { |f| !(f.owner == current_user || f.users.include?(current_user)) }
    folders.each { |f| f[:ftype] = f.owner == current_user ? 'folder' : 'share'; f[:is_owner] = f.owner?(current_user); f[:is_author] = f.author?(current_user) }
    render :json => { :files => folders.as_json + docs.as_json }
  end

  def create
    params[:folder][:parent_id] = nil if params[:folder][:parent_id].blank? || params[:folder][:parent_id] == '0'

    if params[:folder][:parent_id].nil?
      owner = current_user
    else
      parent = Folder.find(params[:folder][:parent_id])
      #validate that the current user can modify the parent folder
      unless parent.owner?(current_user)
        respond_to do |format|
          format.json {render :json => {:success => false, :msg => "The current user is not authorized to make changes to this folder" }, :status => 401}
        end
        return
      end
      owner = parent.owner
    end

    folder = owner.folders.build(params[:folder])
    unless folder.save
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => folder.errors.as_json }, :status => 400}
      end
      return
    end

    folder.audience.recipients(:force => true).length if folder.audience # apply the recipients for the audience so that the mapped joins will actually work

    if(folder.notify_of_audience_addition)
      DocumentMailer.deliver_share_invitation(folder, {:creator => current_user, :users => folder.audience.nil? ? [] : (folder.audience.recipients(:force => true).with_no_hacc) } )
    end

    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end

  def edit
    @folder = Folder.find(params[:id])

    data = {'folder[folder_id]' => @folder.id, 'folder[name]' => @folder.name, 'folder[notify_of_document_addition]' => @folder.notify_of_document_addition,
             'folder[notify_of_audience_addition]' => @folder.notify_of_audience_addition, 'folder[notify_of_file_download]' => @folder.notify_of_file_download,
             'folder[expire_documents]' => @folder.expire_documents, 'folder[notify_before_document_expiry]' => @folder.notify_before_document_expiry,
             'folder[shared]' => @folder.share_status,
             'folder[audience]' => @folder.audience.as_json({:include => {:users => {:only => [:id, :display_name, :email, :title ]},
                                                                  :roles => {:only => [:id, :name]},
                                                                  :jurisdictions => {:only => [:id, :name]},
                                                                  :groups => {:only => [:id, :name]} },
                                                     :only => [:id] })
    }

    @folder.folder_permissions.each_with_index do |permission, index|
      data['folder[permissions][' + index.to_s + '][permission]'] = permission[:permission]
      data['folder[permissions][' + index.to_s + '][user_id]'] = permission[:user_id]      
    end

    respond_to do |format|
      format.json { render :json => {:data => data,
                                     :success => true } }
    end
  end

  def update
    folder = Folder.find(params[:id])

    original_recipients = folder.audience ? Array.new(folder.audience.recipients(:force => true).with_no_hacc) : []

    folder.attributes = params[:folder]

    unless folder.save!
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => @folder.errors.as_json }, :status => 400}
      end
      return
    end

    folder.audience.recipients(:force => true).length if folder.audience # apply the recipients for the audience so that the mapped joins will actually work
    
    if(folder.notify_of_audience_addition)
      DocumentMailer.deliver_share_invitation(folder, {:creator => current_user, :users => folder.audience.nil? ? [] : (folder.audience.recipients(:force => true).with_no_hacc - original_recipients) } )
    end

    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end

  def destroy
    folder = Folder.find(params[:id])
    if !folder.nil? && folder.destroy
      respond_to do |format|
        format.json {render :json => {:success => true } }
      end
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => "Could not remove the document"}, :status => 400}
      end
    end
  end

  def target_folders
    folders = current_user.folders

    unless params[:folder_id].nil?
      current_folder = Folder.find(params[:folder_id]);
      folders = folders - current_folder.self_and_descendants
    end

    folders_json = [{:name => 'My Documents', :id => nil }] + folders.map { |folder| folder.as_json(:only => [:name, :id]) }
    respond_to do |format|
      format.json { render :json => folders_json }
    end
  end

  def move
    folder = Folder.find(params[:id])
    unless params[:parent_id].nil? || params[:parent_id] == 'null' || params[:parent_id].blank?
      target_folder = Folder.find(params[:parent_id])
      if folder.descendants.include?(target_folder)
        respond_to do |format|
          format.json { render :json => {:success => false, :msg => 'Cannot move folder into a folder that it contains.'} }
        end
        return
      end

      folder.move_to_child_of( target_folder )
    else
      # we're moving it into the user's base directory
      folder.parent_id = nil
      folder.save!
    end

    respond_to do |format|
      format.json { render :json => {:success => true } }
    end
  end

  def can_edit_folder
    folder = Folder.find(params[:id])
    unless folder.owner?(current_user)
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => "The current user is not authorized to make changes to this folder" }, :status => 401}
      end
      false
    end
  end
end
