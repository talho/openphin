class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:new, :create]
  
  def index
    @alerts = current_user.alerts_within_jurisdictions
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
      redirect_to @alert
    else
      render :template => "alerts/preview"
    end
  end
  
  def edit
    alert = current_user.alerts.find params[:id]
    @alert = present alert, :action => params[:_action]
    render :template => "alerts/edit_with_#{params[:_action]}"
  end
  
  def cancel
    original_alert = current_user.alerts.find params[:id]
    @alert = original_alert.build_cancellation params[:alert]
    if params[:send]
      @alert.save
      @alert.deliver
      flash[:notice] = "Successfully sent the alert"
      redirect_to logs_path
    else
      render :template => "alerts/preview"
    end
  end
  
  def update
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
