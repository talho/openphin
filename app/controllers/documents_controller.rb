class DocumentsController < ApplicationController
  before_filter :non_public_role_required
  
  def index
    @documents = current_user.documents.inbox
  end
  
  def create
    @document = current_user.documents.build(params[:document])
    
    folder = current_user.folders.find(@document.folder_id)
    unless folder.documents.detect{|x| x.file_file_name = @document.file_file_name}
      @document.save!
    else
      flash[:error] = 'File name is already in use. Try renaming the file.'
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
  
end
