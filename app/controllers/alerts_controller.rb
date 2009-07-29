class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:new, :create]
  skip_before_filter :login_required, :only => :token_acknowledge
  
  def index
    @alerts = current_user.viewable_alerts#_within_jurisdictions
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
      redirect_to alerts_path
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
      redirect_to alerts_path
    else
      @preview = true
      render :edit
    end
  end
  
  def acknowledge
    alert_attempt = current_user.alert_attempts.find_by_alert_id!(params[:id])    

    alert_attempt.acknowledge!
    flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}"
    redirect_to dashboard_path
  end

  def token_acknowledge
    alert_attempt = AlertAttempt.find_by_alert_id_and_token!(params[:id], params[:token])
    if alert_attempt.alert.sensitive?
      flash[:notice] = "You are not authorized to view this page"
    else
      alert_attempt.acknowledge!
      flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}"
    end
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
