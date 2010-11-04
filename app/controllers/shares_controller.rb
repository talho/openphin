class SharesController < ApplicationController
  before_filter :non_public_role_required
  
  layout "documents"
  def new
    begin
      @document = current_user.documents.find(params[:document_id])
      @audience = Audience.new
    rescue
      respond_to do |type|
        type.all { render :nothing => true, :status => 404 }
      end
    end
  end
  
  def create
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new(params[:audience]) unless params[:audience].blank?
    @document.targets.create! :audience => @audience, :creator => current_user if @audience
    if params[:document]
      @document.channel_ids += params[:document][:channel_ids] if params[:document][:channel_ids]
      @document.save!
    end
    flash[:notice] = 'Successfully shared the document'
    redirect_to folder_or_inbox_path(@document)
  end

end
