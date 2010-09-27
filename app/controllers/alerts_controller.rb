require 'ftools'

class AlertsController < ApplicationController
  before_filter :alerter_required, :only => [:index, :new, :create, :edit, :update]
  before_filter :can_view_alert, :only => [:show]
  skip_before_filter :login_required, :only => [:token_acknowledge, :upload, :playback]
  protect_from_forgery :except => [:upload, :playback]

  app_toolbar "han"

  def index
    @alerts = present_collection current_user.alerts_within_jurisdictions(params[:page])
  end

  def show
    alert = Alert.find(params[:id])
    @alert = present alert
    respond_to do |format|
      format.html
      format.pdf do
        prawnto :inline => false
        alerter_required
      end
      format.xml { render :xml => @alert.to_xml( :include => [:author, :from_jurisdiction] , :dasherize => false)}
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        audiences = {:roles => [], :groups => [], :jurisdictions => [], :users => []}
        alert.audiences.each do |audience|
          if audience.name.nil?
            audiences[:roles] = audiences[:roles] | audience.roles.map {|role| role.as_json(:only => ["id", "name"])}
            audiences[:jurisdictions] = audiences[:jurisdictions] | audience.jurisdictions {|jurisdiction| jurisdiction.as_json(:only => ["id", "name"])}
            audiences[:users] = audiences[:users] | audience.users.map {|user| {:id => user.id, :name => user.display_name } }
          else
            audiences[:groups].push(audience.as_json(:only => ["id", "name"]))
          end
        end
        render :json => {:alert => alert.as_json(:include => {:alert_device_types => {:only => ['device']} },
                                      :only => ['acknowledge', 'call_down_messages', 'created_at', 'delivery_time', 'message', 'not_cross_jurisdictional', 'severity', 'short_message', 'status', 'sensitive', 'title']),
                         :alert_attempts => alert.alert_attempts,
                         :audiences => audiences
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
      format.csv do
        alerter_required
        @filename = "alert-#{@alert.identifier}.csv"
        @output_encoding = 'UTF-8'
      end
    end

  end

  def new
    @alert = present Alert.new_with_defaults
    @acknowledge_options = Alert::Acknowledgement
  end

  def create
    remove_blank_call_downs unless params[:alert][:call_down_messages].nil?
    set_acknowledge
    @alert = present current_user.alerts.build(params[:alert])
    @acknowledge = if @alert.acknowledge && !(@alert.call_down_messages.blank? || @alert.call_down_messages.empty?)
      'Advanced'
    elsif @alert.acknowledge
      'Normal'
    else
      'None'
    end
    @acknowledge_options = Alert::Acknowledgement    
    
    if params[:send]
      if @alert.valid?
        params[:alert][:author_id]=current_user.id
        @alert.save
        @alert.integrate_voice
        @alert.batch_deliver
        respond_to do |format|
          format.html {
            flash[:notice] = "Successfully sent the alert."
            redirect_to alerts_path
          }
          format.json { render :json => {:success => true, :alert_path => alert_path(@alert), :id => @alert.id, :title => @alert.title}}
        end
      else
        if @alert.errors['message_recording']
          flash[:error] = "Attached message recording is not a valid wav formatted file."
          @preview = true
        end
        respond_to do |format|
          format.html { render :new }
          format.json { render :json => @alert.errors, :status => :unprocessable_entity}
        end
      end
    else
      @preview = true
      @token = current_user.token
      render :new
    end
  end

  def edit
    alert = Alert.find params[:id]
    @acknowledge_options = Alert::Acknowledgement.reject{|x| x=="Advanced"}
    # TODO : Remove when devices refactored
    @device_types = []
    alert.device_types.each do |device_type|
      @device_types << device_type
    end

    error = false
    msg = nil

    unless alert.is_updateable_by?(current_user)
      msg = "You do not have permission to update or cancel this alert."
      error = true
    end

    unless alert.original_alert.nil?
      msg = "You cannot make changes to updated or cancelled alerts."
      error = true
    end

    if alert.cancelled?
      msg = "You cannot update or cancel an alert that has already been cancelled."
      error = true
    end

    if error
      respond_to do |format|
        format.html do
          flash[:error] = msg
          redirect_to alerts_path
        end
        format.json {render :json => {'success' => false, 'msg' => msg}, :status => 401}
      end
      return
    end

    respond_to do |format|
      format.html do
        @alert = present alert, :action => params[:_action]
        @update = true if params[:_action].downcase == "update"
        @cancel = true if params[:_action].downcase == "cancel"
      end
      format.json do
        audiences = {:roles => [], :groups => [], :jurisdictions => [], :users => []}
        alert.audiences.each do |audience|
          if audience.name.nil?
            audiences[:roles] = audiences[:roles] | audience.roles
            audiences[:jurisdictions] = audiences[:jurisdictions] | audience.jurisdictions
            audiences[:users] = audiences[:users] | audience.users
          else
            audiences[:groups].push(audience)
          end
        end
        render :json => {'alert' => alert, 'devices' => @device_types, 'audiences' => audiences, 'success' => true}
      end
    end
  end

  def update
    original_alert = Alert.find params[:id]
    # TODO : Remove when devices refactored
    @device_types = []
    original_alert.device_types.each do |device_type|
      @device_types << device_type
    end

    unless original_alert.is_updateable_by?(current_user)
      msg = "You do not have permission to update or cancel this alert."
      respond_to do |format|
        format.html do
          flash[:error] = msg
          redirect_to alerts_path
        end
        format.json {render :json => {'message' => msg, 'success' => false}, :status => 401}
      end
    end
    
    if original_alert.cancelled?
      msg = "You cannot update or cancel an alert that has already been cancelled."
      respond_to do |format|
        format.html do
          flash[:error] = msg
          redirect_to alerts_path
        end
        format.json {render :json => {'message' => msg, 'success' => false}, :status => 401}
      end
      return
    end
    reduce_call_down_messages_from_responses(original_alert)
    set_acknowledge
    @alert = if params[:_action].downcase == 'cancel'
      @cancel = true
      original_alert.build_cancellation(params[:alert])
    elsif params[:_action].downcase == 'update'
      @update = true
      original_alert.build_update(params[:alert])
    end
     @acknowledge = if @alert.acknowledge
       'Normal'
     else
       'None'
     end
     @acknowledge_options = Alert::Acknowledgement.reject{|x| x=="Advanced"}
    if params[:send]
      @alert.save
      if @alert.valid?
        @alert.integrate_voice
        @alert.batch_deliver
        respond_to do |format|
          format.html do
            flash[:notice] = "Successfully sent the alert."
            redirect_to alerts_path
          end
          format.json {render :json => {'success' => true}}
        end  
      else
        if @alert.errors['message_recording']
          msg = "Attached message recording is not a valid wav formatted file."
          respond_to do |format|
            format.html do
              flash[:error] = msg
              @preview = true
              render :new
            end
            format.json {render :json => {'message' => msg, 'success' => false}, :status => 406}
          end
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
    respond_to do |format|
      if alert_attempt.nil? || alert_attempt.acknowledged?
        flash[:error] = "Unable to acknowledge alert.  You may have already acknowledged the alert.
        If you believe this is in error, please contact support@#{DOMAIN}."
        format.json {
          headers["Access-Control-Allow-Origin"] = "*"
          headers["Access-Control-Allow-Headers"] = "Cookie"
          render :json => {}, :status => :unprocessable_entity
        }
      else
        device = "Device::EmailDevice" unless params[:email].blank?
        unless params[:call_down_response].blank?
          params[:alert_attempt] = {}
          params[:alert_attempt][:call_down_response] = params[:call_down_response]
        end
        if params[:alert_attempt].blank?
            alert_attempt.acknowledge! device
        else
          device = "Device::EmailDevice" unless params[:email].blank?
          if params[:alert_attempt].nil? || params[:alert_attempt][:call_down_response].nil? || params[:alert_attempt][:call_down_response].empty?
            alert_attempt.acknowledge! device
          else
            alert_attempt.acknowledge! device, params[:alert_attempt][:call_down_response]
          end
          expire_log_entry(alert_attempt.alert)
          flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}."
          format.json {
            headers["Access-Control-Allow-Origin"] = "*"
            headers["Access-Control-Allow-Headers"] = "Cookie"
            render :json => {}, :status => :ok
          }
        end
        if alert_attempt.errors.empty?
          expire_log_entry(alert_attempt.alert)
          flash[:notice] = "Successfully acknowledged alert: #{alert_attempt.alert.title}."
        else
          flash[:error] = "Error: " + alert_attempt.errors["acknowledgement"]
        end
      end
      format.html {redirect_to hud_path}
    end
    # respond_to will look for templates, so I avoid that
#    unless params[:format] == "json"
#      redirect_to hud_path
#    else
#      # this header is a must for CORS
#    end
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

  def set_acknowledge
    if params[:alert][:acknowledge] == 'Advanced' || params[:alert][:acknowledge] == 'Normal'
      params[:alert][:acknowledge] = true
    else
      params[:alert][:acknowledge] = false
    end
  end

  def remove_blank_call_downs
    call_down = params[:alert][:call_down_messages].sort{|a,b| b[0]<=>a[0]}
    call_down.each do |key, value|
      params[:alert][:call_down_messages].delete(key) if value.blank?
      break unless value.blank?
    end
  end
  
  def reduce_call_down_messages_from_responses(original_alert)
    if params[:alert][:call_down_messages].nil? && original_alert.has_alert_response_messages?
      params[:alert][:call_down_messages] = {}
      
      msgs = original_alert.call_down_messages.select{|key, value| params[:alert][:responders].include?(key)}
      
      msgs.each do |key, value|
        params[:alert][:call_down_messages][key] = value
      end
    end
    params[:alert].delete("responders")
  end
  
end
