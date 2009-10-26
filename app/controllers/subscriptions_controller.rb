class SubscriptionsController < ApplicationController
  before_filter :non_public_role_required
  
  def new
    @channel = current_user.owned_channels.find(params[:channel_id])
    @subscription = @channel.subscriptions.build
  end
  
  def create
    @channel = current_user.owned_channels.find(params[:channel_id])
    @audience = Audience.new(params[:audience])
    @channel.targets.create! :audience => @audience, :creator => current_user
    @channel.promote_to_owner(@audience) if params[:owner]
    if params[:channel]
      params[:channel][:audience_ids].each do |id|
        @channel.targets.create! :audience_id => id, :creator => current_user
        @channel.promote_to_owner(Audience.find(id)) if params[:owner]
      end
    end

    flash[:notice] = "Additional #{params[:owner] ? 'owners' : 'users'} have been added to this channel"
    redirect_to documents_path
  end

end
