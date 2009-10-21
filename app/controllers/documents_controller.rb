class DocumentsController < ApplicationController
  before_filter :non_public_role_required
  
  def index
    @documents = current_user.documents.inbox
  end
  
  def create
    @share = current_user.shares.build(params[:share])
    @share.save!
    redirect_to @share.folder ? @share.folder : documents_path
  end
  
  def show
    @document = current_user.documents.find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
end
