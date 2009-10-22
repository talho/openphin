class ChannelsController < ApplicationController
  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(params[:channel])
    @channel.save!
    flash[:notice] = 'Successfully created the channel'
    redirect_to @channel
  end
  
  def show
    @channel = Channel.find(params[:id])
    @documents = []
    render 'documents/index'
  end
end
