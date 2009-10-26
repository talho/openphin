class DocumentsController < ApplicationController
  before_filter :non_public_role_required
  
  def index
    @documents = current_user.documents.inbox
  end
  
  def create
    @document = current_user.documents.build(params[:document])
    @document.save!
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
  
end
