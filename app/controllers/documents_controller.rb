class DocumentsController < ApplicationController
  def index
    @documents = current_user.documents
    @folders = current_user.folders.roots
  end
  
  def create
    @document = current_user.documents.build(params[:document])
    @document.save!
    redirect_to documents_path
  end
  
  def show
    @document = current_user.documents.find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
end
