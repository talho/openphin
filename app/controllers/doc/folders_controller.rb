class Doc::FoldersController < ApplicationController
  before_filter :non_public_role_required
  before_filter :can_edit_folder, :only => [:edit, :update, :move, :destroy]

  respond_to :json, :only => [:index, :show]

  def index
    @folders = Folder.get_formatted_folders(current_user) + Folder.get_formatted_shares(current_user)
    respond_with(@folders)
  end

  def show
    folder = params[:id].nil? || params[:id] == 'null' ? nil : Folder.find(params[:id])
    unless folder.nil? || folder.owner == current_user || folder.users.include?(current_user)
      render :json => { :files => [] }
      return
    end

    @documents = (folder.nil? ? current_user.documents.inbox : folder.documents).order('file_file_name')
    @folders = (folder.nil? ? current_user.folders.rootsm : folder.children).order('name')
    @folders.select! { |f| f.owner == current_user || f.users.include?(current_user) }
    respond_with(@documents, @folders)
  end

  def create
    params[:folder][:parent_id] = nil if params[:folder][:parent_id].blank? || params[:folder][:parent_id] == '0' || params[:folder][:parent_id] == 'null'    
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
      
      #Ensure folders under organization maintain a nil user and the organization id
      if parent.organization_id.present?
        params[:folder][:organization_id] = parent.organization_id
      end
    end
    
    params[:folder][:user_id] = owner.id unless owner.nil?
    
    folder = Folder.new params[:folder]
    unless folder.save
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => folder.errors.as_json }, :status => 400}
      end
      return
    end

    if(folder.notify_of_audience_addition)
      DocumentMailer.share_invitation(folder, {:creator => current_user, :users => folder.audience.recipients } ).deliver unless folder.audience.nil? || folder.audience.recipients.empty?
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

    original_recipients = folder.audience ? Array.new(folder.audience.recipients) : []

    folder.attributes = params[:folder]

    unless folder.save!
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => @folder.errors.as_json }, :status => 400}
      end
      return
    end
    
    if folder.notify_of_audience_addition
      aud = folder.audience.nil? ? [] : (folder.audience.recipients(true) - original_recipients)
      DocumentMailer.share_invitation(folder, {:creator => current_user, :users => aud } ).deliver unless aud.empty?
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
    if params[:folder_id].present?
      current_folder = Folder.find(params[:folder_id])
      if current_folder.user_id == current_user.id
        folders = current_user.folders
      elsif current_folder.user_id.present?            
        folders = Folder.joins(:folder_permissions).where("folder_permissions.user_id = ? and folder_permissions.permission = ? and folders.user_id = ? ", current_user.id, FolderPermission::PERMISSION_TYPES[:admin], current_folder.user_id)
      else
        if current_folder.organization.contact.id == current_user.id
          folders = Folder.where(organization_id: current_folder.organization_id) 
        else
          folders = Folder.joins(:folder_permissions).where("folder_permissions.user_id = ? and folder_permissions.permission = ? and folders.organization_id = ? ", current_user.id, FolderPermission::PERMISSION_TYPES[:admin], current_folder.organization_id)
        end
      end
      folders = folders - current_folder.self_and_descendants
    else
      folders = Folder.joins(:folder_permissions).where("folder_permissions.user_id = ? and folder_permissions.permission in (?)", current_user.id, [FolderPermission::PERMISSION_TYPES[:admin], FolderPermission::PERMISSION_TYPES[:author]])
      folders += current_user.folders
    end
    
    folders_json = (current_folder.user_id.present? ? [{:name => 'My Documents', :id => nil }] : []) + folders.map { |folder| folder.as_json(:only => [:name, :id]) }
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
