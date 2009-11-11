class DocumentsController < ApplicationController
  before_filter :non_public_role_required
  
  def index
    @documents = current_user.documents.inbox
    @folder = current_user.folders
  end
  
  def create
    folder = current_user.folders.find(params[:document][:folder_id].to_i)
    unless folder.documents.detect{|x| x.file_file_name == params[:document][:file].original_filename}
      @document = current_user.documents.build(params[:document])
      @document.save!
    else
      flash[:error] = 'File name is already in use. Try renaming the file.'
      @document = current_user.documents.build(params[:document])
    end
    redirect_to folder_or_inbox_path(@document)
  end
  
  def show
    @document = Document.viewable_by(current_user).find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
  
  def edit
    @document = Document.editable_by(current_user).find(params[:id])
  end
  
  def update
    @document = Document.editable_by(current_user).find(params[:id])
    if @document.update_attributes(params[:document])
      redirect_to folder_or_inbox_path(@document)
    else 
      render :edit
    end
  end
  
  def copy
    @document = Document.viewable_by(current_user).find(params[:id])
  end
  
  def remove_from_channel
    @document = Document.editable_by(current_user).find(params[:id])
    @channel = current_user.channels.find(params[:channel_id])
    @channel.documents.delete(@document)
    flash[:notice] = "Successfully removed the document from the channel"
    redirect_to @channel
  end
  
  def remove_from_folder
    @document = Document.editable_by(current_user).find(params[:id])
    @folder = current_user.folders.find(params[:folder_id])
    @folder.documents.delete(@document)
    @document.destroy
    flash[:notice] = "Successfully removed the document from the folder."
    redirect_to @folder
  end
  
end
