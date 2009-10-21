class SharesController < ApplicationController
  def new
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new
  end
  
  def create
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new(params[:audience])
    @document.targets.create! :audience => @audience, :creator => current_user
    flash[:notice] = 'Successfully shared the document'
    redirect_to documents_path
  end
end
