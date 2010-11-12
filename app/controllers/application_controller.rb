# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include CachingPresenter::InstantiationMethods
  include Clearance::Authentication
  #include ExceptionNotifiable
  helper :all # include all helpers, all the time
  helper_method :toolbar
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :login_required, :set_locale, :except => :options
  before_filter :add_cors_header, :only => :options

  layout :choose_layout

  cattr_accessor :applications
  @@applications=HashWithIndifferentAccess.new

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def phin_oid_prefix
    "#{PHIN_PARTNER_OID}.#{PHIN_APP_OID}.#{PHIN_ENV_OID}"
  end

  def admin_or_self_required(var = :id)
    ensure_admin_or_self(params[var])
  end
  
  def ensure_admin_or_self(user_id)
    unless current_user.role_memberships.detect{ |rm| rm.role == Role.admin || rm.role == Role.superadmin } || current_user.id.to_s == user_id.to_s
      flash[:error] = "That resource does not exist or you do not have access to it."
      redirect_to root_path
      false
    end
  end

  def toolbar
	  self.class.app_toolbar
  end

  def options
    render :nothing => true, :status => 200
  end

  def choose_layout
    if signed_in?
      if request.xhr? || request.format.ext?
        "ext_panel"
      else
        "application"
      end
    else
      "non_application"
    end
  end

  rescue_from Exception, :with => :render_error
  
  protected

  def folder_or_inbox_path(document)
    document.folder ? folder_documents_path(document.folder) : folder_inbox_path
  end

  def login_required
    store_location
    unless signed_in?
      respond_to do |format|
        format.html{ redirect_to sign_in_path }
        format.ext{ redirect_to sign_in_path }
        format.json do
          headers["Access-Control-Allow-Origin"] = "*"
          render :json => ['SESSION' => 'EXPIRED']
        end
      end
      false
    end
  end

  def admin_required
    unless current_user.role_memberships.detect{ |rm| rm.role == Role.admin  || rm.role == Role.superadmin }
      message = "That resource does not exist or you do not have access to it."
      if request.xhr?
        respond_to do |format|
          format.html {render :text => message, :status => 404}
          format.json {render :json => {:message => message}, :status => 404}
        end
      else
        flash[:error] = message
        redirect_to root_path
      end
      false
    end
  end

  def non_public_role_required
    unless current_user.has_non_public_role?
      if request.xhr?
        respond_to do |format|
            format.html {render :text => "You are not authorized to view this page", :status => 401}
            format.json {render :json => {:message => "You are not authorized to view this page"}, :status => 401}
        end
      else
        flash[:error] = "You are not authorized to view this page."
        redirect_to root_path
      end
      false
    end
  end

  def can_view_alert
    alert = Alert.find(params[:id])
    unless !alert.nil? &&
        (alert.recipients.include?(current_user) ||
          alert.from_jurisdiction.self_and_ancestors.detect{|j| j.han_coordinators.include?(current_user)})
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

  def app_toolbar(toolbar, options = {})
    if toolbar.nil?
      @toolbar.blank? ? self.class.app_toolbar(toolbar, options) : @toolbar
    else
      @toolbar = toolbar
    end

  end

  def self.app_toolbar(toolbar=nil, options = {}  )
    if toolbar.blank?
      toolbar_partial = @toolbar.blank? ? self.controller_name : @toolbar
      @toolbar = "application"
      view_paths.each do |path|
        @toolbar = toolbar_partial if File.exist?(File.join(path, 'toolbars', "_#{toolbar_partial}.html.erb"))
      end
    else
      @toolbar = toolbar
    end
    @toolbar
  end

  def add_cors_header
    # Allows for Cross-Origin Resource Sharing (http://www.w3.org/TR/cors/) to access json data from an external source
    # Add an appropriate route on the methods you expect to POST data to using ajax but be sure to test out authenticity tokens to prevent XSS attacks:
    # map.connect "/url.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}
    # Also add headers["Access-Control-Allow-Origin"] = "*" to your json response
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "OPTIONS"
    headers["Access-Control-Allow-Headers"] = "X-Requested-With, Cookie"
    headers["Access-Control-Max-Age"] = "1728000"
  end

  def self.if_not_xhr(specified_layout)
    proc { |controller| controller.request.xhr? ? nil : specified_layout }
  end

  def self.if_not_ext(specified_layout)
    proc { |controller| controller.request.format.ext? ? nil : specified_layout }
  end

  def update_devices(device_list_json)
    device_list = ActiveSupport::JSON.decode(device_list_json)
    success = true
    device_errors = []

    # Device: class to attr_name map
    deviceOptionMap = {
      'Device::EmailDevice' =>      'email_address',
      'Device::PhoneDevice' =>      'phone',
      'Device::SMSDevice' =>        'sms',
      'Device::FaxDevice' =>        'fax',
      'Device::BlackberryDevice' => 'blackberry'
    }
    device_list.find_all{|d| d["state"]=="deleted" && d["id"] > 0}.each { |d|
      device_to_delete = Device.find(d["id"])
      device_to_delete.destroy if @user == device_to_delete.user
    }
    device_list.find_all{|d| d["state"]=="new"}.each { |d|
      attr_name = deviceOptionMap[d["rbclass"]]
      new_device = d["rbclass"].constantize.new({attr_name => d["value"]})
      new_device.user = @user
      if !new_device.save
        success = false
        device_errors.concat(new_device.errors.full_messages)
      end
    }

    [ success, device_errors ]
  end

  def handle_role_requests(req_json)
    rq_list = ActiveSupport::JSON.decode(req_json)
    result = "success"
    rq_errors = []

    ActiveRecord::Base.transaction {
      rq_list.find_all{|rq| rq["state"]=="deleted" && rq["id"] > 0}.each { |rq|
        rqType = (rq["type"]=="req") ? RoleRequest : RoleMembership
        rq_to_delete = rqType.find(rq["id"])
        if rq_to_delete && @user == rq_to_delete.user
          rq_to_delete.destroy
        else
          rq_errors.concat(rq_to_delete.errors.full_messages)
        end
      }
      rq_list.find_all{|rq| rq["state"]=="new"}.each { |rq|
        jurisdiction = Jurisdiction.find(rq["jurisdiction_id"])
        role = Role.find(rq["role_id"])
        role_request = RoleRequest.new
        role_request.jurisdiction_id = rq["jurisdiction_id"]
        role_request.role_id = rq["role_id"]
        role_request.requester = @user
        role_request.user = @user
        if role_request.save && role_request.valid?
          RoleRequestMailer.deliver_user_notification_of_role_request(role_request) if !role_request.approved?
        else
          result = "failure"
          rq_errors.concat(role_request.errors.full_messages)
        end
      }

      if @user.role_memberships.public_roles.empty?
        result = "rollback"
        rq_errors.push("You must have at least one public role.  Please add a public role and re-save.")
        raise ActiveRecord::Rollback
      end
    }

    [ result, rq_errors ]
  end

private

  # This makes #present always pass set the current_user on the presenter
  # if the presenter accepts :current_user.
  def present_with_current_user(*args)
    returning present_without_current_user(*args) do |presenter|
      if presenter.accepts?(:current_user)
        presenter.instance_variable_set :@current_user, current_user
      end
    end
  end
  alias_method_chain :present, :current_user
  helper_method :present
  helper_method :present_collection

  def assign_public_role_if_no_role_is_provided
    role_requests = params[:user][:role_requests_attributes]
    role_requests.each_value do |role_request|
      role_request["role_id"] = Role.public.id.to_s if role_request["role_id"].blank? && !role_request["jurisdiction_id"].blank?
    end
  end

  def remove_blank_role_requests
    params[:user][:role_requests_attributes].each do |key,value|
      params[:user][:role_requests_attributes].delete(key) if (value["jurisdiction_id"].blank? && value["role_id"].blank?)
    end
  end
  
  def set_locale
    I18n.locale = :en
  end

  def sign_in(user)
    user.update_attribute(:last_signed_in_at, Time.now)
    super user
  end

  def render_error(exception)
    log_error(exception)
    notify_hoptoad(exception)
    if request.format.to_sym == :json
      if Rails.env.downcase == "production"
        render :json => {:success => false, :error => "There was an error processing your request.  Please contact technical support."}.as_json
      else
        render :json => {:success => false, :error => "There was an error processing your request.  Please contact technical support.", :exception => h(exception.to_s), :backtrace => exception.backtrace.each{|b| h(b)}}.as_json
      end
    else
      local_request? ? rescue_action_locally(exception) : rescue_action_in_public(exception)
    end
  end

  def render_json_error_as_html(exception)
    log_error(exception)
    notify_hoptoad(exception)
    if Rails.env.downcase == "production"
      render :json => {:success => false, :error => "There was an error processing your request.  Please contact technical support."}.as_json, :content_type => 'text/html'
    else
      render :json => {:success => false, :error => "There was an error processing your request.  Please contact technical support.", :exception => h(exception.to_s), :backtrace => exception.backtrace.each{|b| h(b)}}.as_json, :content_type => 'text/html'
    end
  end

  def force_json_as_html
    self.class.rescue_from Exception, :with => :render_json_error_as_html
  end
end
