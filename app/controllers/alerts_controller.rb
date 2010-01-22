require 'ftools'

class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:new, :create, :edit, :update]
  before_filter :can_view_alert, :only => [:show]
  skip_before_filter :login_required, :only => [:token_acknowledge, :upload, :playback]
  protect_from_forgery :except => [:upload, :playback]

  app_toolbar "han"

  def index
    @alerts = present_collection current_user.alerts_within_jurisdictions(params[:page])
  end

  def show
    @alert = present Alert.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @alert.to_xml( :include => [:author, :from_jurisdiction] , :dasherize => false)}
      format.csv do
        alerter_required
        @filename = "alert-#{@alert.to_param}.csv"
        @output_encoding = 'UTF-8'
      end
    end

  end

  def new
    @alert = present Alert.new_with_defaults
  end

  def create
    @alert = present current_user.alerts.build(params[:alert])
    if params[:send]
      if @alert.valid?
        @alert.save
        @alert.integrate_voice
        @alert.batch_deliver
        flash[:notice] = "Successfully sent the alert."
        redirect_to alerts_path
      else
        if @alert.errors['message_recording']
          flash[:error] = "Attached message recording is not a valid wav formatted file."
          @preview = true
        end
        render :new
      end
    else
      @preview = true
      @token = current_user.token
      render :new
    end
  end

  def edit
    alert = Alert.find params[:id]
    # TODO : Remove when devices refactored
    @device_types = []
    alert.device_types.each do |device_type|
      @device_types << device_type
    end

    unless alert.is_updateable_by?(current_user)
      flash[:error] = "You do not have permission to update or cancel this alert."
      redirect_to alerts_path
    end

    unless alert.original_alert.nil?
      flash[:error] = "You cannot make changes to updated or cancelled alerts."
      redirect_to alerts_path
    end
    @alert = present alert, :action => params[:_action]
    @update = true if params[:_action].downcase == "update"
    @cancel = true if params[:_action].downcase == "cancel"
  end

  def update
    original_alert = Alert.find params[:id]
    # TODO : Remove when devices refactored
    @device_types = []
    original_alert.device_types.each do |device_type|
      @device_types << device_type
    end

    unless original_alert.is_updateable_by?(current_user)
      flash[:error] = "You do not have permission to update or cancel this alert."
      redirect_to alerts_path
    end
    
    if original_alert.cancelled?
      flash[:error] = "You cannot update or cancel an alert that has already been cancelled."
      redirect_to alerts_path
      return
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
        flash[:notice] = "Successfully sent the alert."
        redirect_to alerts_path
      else
        if @alert.errors['message_recording']
          flash[:error] = "Attached message recording is not a valid wav formatted file."
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
      flash[:error] = "Unable to acknowledge alert.  You may have already acknowledged the alert.
      If you believe this is in error, please contact support@#{DOMAIN}."
    else
      if params[:email].blank?
        alert_attempt.acknowledge!
      else
        alert_attempt.acknowledge! "Device::EmailDevice"
      end
      expire_log_entry(alert_attempt.alert)
      flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}."
    end
    redirect_to hud_path
  end

  def token_acknowledge
    alert_attempt = AlertAttempt.find_by_alert_id_and_token(params[:id], params[:token])
    if alert_attempt.nil? || alert_attempt.acknowledged?
      flash[:error] = "Unable to acknowledge alert.  You may have already acknowledged the alert.
      If you believe this is in error, please contact support@#{DOMAIN}."
    else
      if alert_attempt.alert.sensitive?
        flash[:error] = "You are not authorized to view this page."
      else
        alert_attempt.acknowledge! "Device::EmailDevice"
        expire_log_entry(alert_attempt.alert)
        flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}."
      end
    end
    redirect_to hud_path
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
    if(File.size(temp.path) > 7000000) # sufficiently below 10Meg (21CC attachment limitation) after Base64 encoding
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

  def expire_log_entry(alert)
    expire_fragment(:controller => "alerts", :action => "index", :key => ['alert_log_entry', alert.id])    
  end
  def alerter_required
    unless current_user.alerter?
      flash[:error] = "You do not have permission to send an alert."
      redirect_to root_path
    end
  end

end
