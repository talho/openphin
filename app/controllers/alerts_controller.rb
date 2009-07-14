class AlertsController < ApplicationController
  def index
    
  end
  
  def new
    @alert = Alert.new
  end
  
  def create
    @alert = Alert.new params[:alert]
  end
end
