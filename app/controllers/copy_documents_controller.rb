class CopyDocumentsController < ApplicationController
  before_filter :non_public_role_required, :find_document
  layout "documents"
  
  def show
  end

  def new
  end
  
  def create
    @new_document = @document.copy(current_user)
    @new_document.update_attributes!(params[:document])
    flash[:notice] = 'Successfully copied the document'
    redirect_to documents_panel_path
  end

  def update
    @audience = Audience.new(params[:audience])
    @document.targets.create! :audience => @audience, :creator => current_user
    if params[:document]
      if params[:document][:audience_ids]
        params[:document][:audience_ids].each do |id|
          @document.targets.create! :audience_id => id, :creator => current_user
        end
      end
      @document.save!
    end
    flash[:notice] = 'Successfully copied the document'
    if current_user.documents.find(:first, @document.id)
      redirect_to folder_or_inbox_path(@document)
    else
      redirect_to folder_inbox_path
    end
  end

private

  def find_document()
    @document = Document.find(params[:document_id])
    @document = nil unless @document.viewable_by?(current_user)
  end
  
end
