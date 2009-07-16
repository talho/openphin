class AlertsController < ApplicationController
  def index
    
  end
  
  def new
    @alert = Alert.new
  end
  
  def show
    @alert = Alert.find(params[:id])
  end
  
  def create
    @alert = current_user.alerts.build params[:alert]
    if params[:send]
      @alert.save
      @alert.deliver
      flash[:notice] = "Successfully sent the alert"
      redirect_to logs_path
    end
  end
end
