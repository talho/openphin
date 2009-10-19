class SharesController < ApplicationController
  def new
    @document = current_user.documents.find(params[:document_id])
    @share = Share.new
  end
end
