class DocumentsController < ApplicationController
  before_filter :non_public_role_required
  
  def index
    @documents = current_user.documents.inbox
  end
  
  def create
    @document = current_user.documents.build(params[:document])
    @document.save!
    redirect_to_folder
  end
  
  def show
    @document = current_user.documents.find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
  
  def edit
    @document = current_user.documents.find(params[:id])
  end
  
  def update
    @document = current_user.documents.find(params[:id])
    if @document.update_attributes(params[:document])
      redirect_to_folder
    else 
      render :edit
    end
  end
  
private
  def redirect_to_folder
    redirect_to @document.folder ? @document.folder : documents_path
  end
end
