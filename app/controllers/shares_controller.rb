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
  
  def edit
    find_share
  end
  
  def update
    find_share
    @share.update_attributes(params[:share])
    redirect_to documents_path
  end
  
private
  def find_share
    @share = current_user.shares.find_by_id_and_document_id(params[:id], params[:document_id])
  end
end
