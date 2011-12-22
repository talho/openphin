class AlertsController < ApplicationController
  skip_before_filter :login_required, :only => [:show_with_token, :update_with_token]
  before_filter :find_alert, :except => [:recent_alerts]
  before_filter :can_view_alert, :only => [:show, :update]
  
  def show
    @current_user = current_user
    set_view_variables
    render :layout => false
  end

  def show_with_token
    @alert_attempt = AlertAttempt.find_by_alert_id_and_token(@alert.id, params[:token])
    if @alert_attempt.nil?
      error = "That resource does not exist or you do not have access to it."
      if request.xhr?
        respond_to do |format|
            format.html {render :text => error, :status => 404}
            format.json {render :json => {:message => error}, :status => 404}
        end
      else
        flash[:error] = error
        redirect_to root_path
      end
      return
    end
    @current_user = @alert_attempt.user
    
    set_view_variables
    
    render :layout => false
  end
  
  def update
    respond_to do |format|
      if @alert_attempt.update_attributes :acknowledged_at => Time.now, :call_down_response => params[:response].to_i
        format.json { render :json => {:success => true} }
      else
        format.json { render :json => {:success => false, :errors => @alert_update.errors}, :status => 400 }
      end
    end
  end
  
  def update_with_token
    @alert_attempt = AlertAttempt.find_by_alert_id_and_token(@alert.id, params[:token])
    @current_user = @alert_attempt.user
    
    self.update
  end
  
  def recent_alerts
    @alerts = current_user.alert_attempts.order('created_at desc').limit(5).map(&:alert)
    
    respond_to do |format|
      format.json {render :json => @alerts.map{|a| a.as_json(:only => [:title, :message, :alert_type, :id, :created_at])}}
    end
  end
  
  private
  
  def set_view_variables
    @console_message = Service::TALHO::Console::Message.new(:message => MessageApi.parse(@alert.to_xml), :user => @current_user)
    if @alert.acknowledge && @alert.methods.include?('call_downs')
      @call_downs = @alert.call_downs(@current_user)
    end
  end 
  
  def can_view_alert
    @alert_attempt = AlertAttempt.find_by_alert_id_and_user_id(@alert.id, current_user.id)
    if @alert_attempt.nil?
      error = "That resource does not exist or you do not have access to it."
      if request.xhr?
        respond_to do |format|
            format.html {render :text => error, :status => 404}
            format.json {render :json => {:message => error}, :status => 404}
        end
      else
        flash[:error] = error
        redirect_to root_path
      end
    end
  end
  
  def find_alert
    @alert = Alert.find(params[:id])
    @alert = @alert.alert_type.constantize.find(@alert)
  end
end
