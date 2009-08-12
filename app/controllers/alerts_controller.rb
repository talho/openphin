require 'ftools'

class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:new, :create]
  skip_before_filter :login_required, :only => [:token_acknowledge, :upload, :playback]
  protect_from_forgery :except => [:upload, :playback]
  
  def index
    @alerts = present_collection current_user.viewable_alerts
  end
  
  def show
    @alert = present Alert.find(params[:id])
  end
  
  def new
    @alert = present Alert.new_with_defaults
  end
  
  def create
    @alert = present current_user.alerts.build(params[:alert])
    #params[:alert][:user_ids].each do |user_id|
    #  user = nil
    #  user = User.find_by_id(user_id) if user_id.split.size > 0
    #  @alert.users << user if user
    #end
    if params[:send]
      @alert.save
      if @alert.valid?
        @alert.integrate_voice
        @alert.batch_deliver
        flash[:notice] = "Successfully sent the alert"
        redirect_to alerts_path
      else
        if @alert.errors['message_recording']
          flash[:notice] = "<b>Attached message recording is not a valid wav formatted file</b>"
          @preview = true
          render :new
        end
      end
    else
      @preview = true
      @token = current_user.token
      render :new
    end
  end
  
  def edit
    alert = current_user.alerts.find params[:id]
    # TODO : Remove when devices refactored
    @devices = []
    alert.devices.each do |device|
      @devices << device
    end

    if !alert.original_alert.nil?
      flash[:notice] = "You cannot make changes to updated or cancelled alerts"
      redirect_to alerts_path
    end
    @alert = present alert, :action => params[:_action]
    @update = true if params[:_action].downcase == "update"
    @cancel = true if params[:_action].downcase == "cancel"
  end
  
  def update
    original_alert = current_user.alerts.find params[:id]
    # TODO : Remove when devices refactored
    @devices = []
    original_alert.devices.each do |device|
      @devices << device
    end

    @alert = if params[:_action].downcase == 'cancel'
      @cancel = true
      original_alert.build_cancellation(params[:alert])
    elsif params[:_action].downcase == 'update'
      @update = true
      original_alert.build_update(params[:alert])
    end
    if params[:send]
      @alert.save
      if @alert.valid?
        @alert.integrate_voice
        @alert.batch_deliver
        flash[:notice] = "Successfully sent the alert"
        redirect_to alerts_path
      else
        if @alert.errors['message_recording']
          flash[:notice] = "<b>Attached message recording is not a valid wav formatted file</b>"
          @preview = true
          render :new
        end
      end
    else
      @alert = present @alert
      @preview = true
      render :edit
    end
  end
  
  def acknowledge
    alert_attempt = current_user.alert_attempts.find_by_alert_id(params[:id])
    if alert_attempt.nil? || alert_attempt.acknowledged?
      flash[:notice] = "Unable to acknowledge alert.  You may have already acknowledged the alert.  
      If you believe this is in error, please contact support@#{HOST}."
    else
      alert_attempt.acknowledge!
      flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}"
    end
    redirect_to dashboard_path
  end

  def token_acknowledge
    alert_attempt = AlertAttempt.find_by_alert_id_and_token(params[:id], params[:token])
    if alert_attempt.nil? || alert_attempt.acknowledged?
      flash[:notice] = "Unable to acknowledge alert.  You may have already acknowledged the alert.  
      If you believe this is in error, please contact support@#{HOST}."
    else
      if alert_attempt.alert.sensitive?
        flash[:notice] = "You are not authorized to view this page"
      else
        alert_attempt.acknowledge!
        flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}"
      end
    end
    redirect_to dashboard_path
  end
  
  def upload
    # Takes uploaded file info from JavaSonicRecorderUploader, copies to permanent location, and returns SUCCESS or ERROR
    user = User.find_by_token(params[:token]) if !params[:token].blank?
    if user.blank? || user.token_expires_at.blank? || user.token_expires_at < Time.zone.now || !user.alerter? || params[:userfile].blank?
      render :upload_error, :layout => false
      return
    end
    temp = params[:userfile]
    if(!File.exists?(temp.path))
      render :upload_error, :layout => false
    end
    newpath = "#{RAILS_ROOT}/message_recordings/tmp/#{user.token}.wav"
    File.copy(temp.path,newpath)
    if(!File.exists?(newpath))
      render :upload_error, :layout => false
    end
    render :upload_success, :layout => false
  end
  
  def playback
    filename = "#{RAILS_ROOT}/message_recordings/tmp/#{params[:token]}.wav"
    if File.exists?(filename)
      @file = File.read(filename)
    end
    response.headers["Content-Type"] = 'audio/x-wav'
    render :play, :layout => false
  end
  
private
  
  def alerter_required
    unless current_user.alerter?
      flash[:notice] = "You do not have permission to send an alert."
      redirect_to root_path
    end
  end
  
end
