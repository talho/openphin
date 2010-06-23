class ChannelsController < ApplicationController
  before_filter :non_public_role_required

  layout "documents", :except => "popup_channel"
  layout "application", :only => "popup_channel"

  def new
    @channel = current_user.channels.build
  end

  def create
    @channel = current_user.channels.build
    subscription = current_user.subscriptions.build(
      :owner => true, 
      :channel => Channel.new(params[:channel])
    )
    subscription.save!
    flash[:notice] = 'Successfully created the share'
    redirect_to documents_panel_path
  end

  def show
    @channel = current_user.channels.find(params[:id])
    @documents = @channel.documents
  end
  
  def unsubscribe
    subscription = current_user.subscriptions.find_by_channel_id!(params[:id])
    if((subscription.channel.owners.count == 1 && !subscription.channel.owners.include?(current_user)) || subscription.channel.owners.count > 1)
      current_user.subscriptions.delete subscription
      flash[:notice] = "Successfully unsubscribed from the share"
    else
      flash[:notice] = "You can not be removed as owner, since you are the only owner"
    end
    redirect_to documents_panel_path
  end
  
  def destroy
    @channel = current_user.owned_channels.find(params[:id])
    @channel.destroy
    flash[:notice] = "Successfully deleted the share"
    redirect_to documents_panel_path
  end
  
  def show_destroy
    @channel = current_user.owned_channels.find(params[:id])
  end

  def popup_channel
    @channel = current_user.channels.find(params[:id])
  end
end
