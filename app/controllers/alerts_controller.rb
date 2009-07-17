class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:new, :create]
  
  def index
  end
  
  def show
    @alert = Alert.find(params[:id])
  end
  
  def new
    @alert = Alert.new
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
  
private
  
  def alerter_required
    unless current_user.alerter?
      flash[:notice] = "You do not have permission to send an alert."
      redirect_to root_path
    end
  end
  
end
