class CopyDocumentsController < ApplicationController
  before_filter :non_public_role_required, :find_document
  
  def show
  end
  
  def create
    @new_document = @document.copy(current_user)
    @new_document.update_attributes!(params[:document])
    flash[:notice] = 'Successfully copied the document'
    redirect_to documents_panel_path
  end
  
private

  def find_document
    @document = Document.viewable_by(current_user).find(params[:document_id])
  end
  
end
