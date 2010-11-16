class Shares2Controller < ApplicationController
  before_filter :non_public_role_required
  
  layout "documents"
  def new
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new
  end
  
  def create
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new(params[:audience]) unless params[:audience].blank?
    @document.targets.create! :audience => @audience, :creator => current_user if @audience
    if params[:document]
      @document.share_ids += params[:document][:share_ids] if params[:document][:share_ids]
      @document.save!
    end
    flash[:notice] = 'Successfully shared the document'
    redirect_to folder_or_inbox_path(@document)
  end

end
