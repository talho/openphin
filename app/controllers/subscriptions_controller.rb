class SubscriptionsController < ApplicationController
  before_filter :non_public_role_required
  
  layout "documents"
  def new
    @share = current_user.owned_shares.find(params[:share_id])
    @subscription = @share.subscriptions.build
  end
  
  def create
    @share = current_user.owned_shares.find(params[:share_id])
    @audience = Audience.new(params[:audience])
    @share.targets.create! :audience => @audience, :creator => current_user
    @share.promote_to_owner(@audience) if params[:owner]
    if params[:share]
      params[:share][:audience_ids].each do |id|
        @share.targets.create! :audience_id => id, :creator => current_user
        @share.promote_to_owner(Audience.find(id)) if params[:owner]
      end
    end

    flash[:notice] = "Additional #{params[:owner] ? 'owners' : 'users'} have been added to this share"
    redirect_to documents_panel_path
  end

end
