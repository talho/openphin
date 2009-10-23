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
    flash[:notice] = 'Successfully created the channel'
    redirect_to subscription.channel
  end
  
  def show
    @channel = current_user.channels.find(params[:id])
    @documents = @channel.documents
    render 'documents/index'
  end
end
