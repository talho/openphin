class ChannelsController < ApplicationController
  before_filter :non_public_role_required
  
  def new
    @channel = current_user.channels.build
  end

  def create
    subscription = current_user.subscriptions.build(
      :owner => true, 
      :channel => Channel.new(params[:channel])
    )
    subscription.save!
    flash[:notice] = 'Successfully created the share'
    redirect_to subscription.channel
  end
  
  def show
    @channel = current_user.channels.find(params[:id])
    @documents = @channel.documents
    render 'documents/index'
  end
  
  def unsubscribe
    subscriptions = current_user.subscriptions
    subscriptions.delete subscriptions.find_by_channel_id!(params[:id])
    flash[:notice] = "Successfully unsubscribed from the share"
    redirect_to documents_path
  end
  
  def destroy
    @channel = current_user.owned_channels.find(params[:id])
    @channel.destroy
    flash[:notice] = "Successfully deleted the share"
    redirect_to documents_path
  end
end
