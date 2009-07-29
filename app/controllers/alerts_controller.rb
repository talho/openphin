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
      redirect_to logs_path
    else
      @preview = true
      render :new
    end
  end
  
  def edit
    alert = current_user.alerts.find params[:id]
    @alert = present alert, :action => params[:_action]
  end
  
  def update
    original_alert = current_user.alerts.find params[:id]
    @alert = if params[:_action] == 'cancel'
      original_alert.build_cancellation(params[:alert])
    else
      # TODO: implement this
      # original_alert.build_update(params[:alert])
    end
    if params[:send]
      @alert.save
      @alert.deliver
      flash[:notice] = "Successfully sent the alert"
      redirect_to logs_path
    else
      @preview = true
      render :edit
    end
  end
  
  def acknowledge
    if signed_in?
      alert_attempt = Alert.find(params[:id]).alert_attempts.find_by_user_id!(current_user.id)    
    else
      alert_attempt = current_user.alert_attempts.find_by_alert_id_and_token!(params[:id], params[:token])
    end
    alert_attempt.acknowledge!
    flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}"
    redirect_to dashboard_path
  end

  
private
  
  def alerter_required
    unless current_user.alerter?
      flash[:notice] = "You do not have permission to send an alert."
      redirect_to root_path
    end
  end
  
end
