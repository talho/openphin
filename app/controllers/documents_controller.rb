class DocumentsController < ApplicationController
  def index
    @documents = current_user.documents
    @folders = current_user.folders.roots
    @share = Share.new
  end
  
  def create
    @share = current_user.shares.build(params[:share])
    @share.save!
    redirect_to documents_path
  end
  
  def show
    @document = current_user.documents.find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
end
