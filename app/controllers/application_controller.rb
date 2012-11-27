# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include CachingPresenter::InstantiationMethods
  include Clearance::Authentication

  helper :all # include all helpers, all the time
  helper_method :toolbar, :current_user, :current_app
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :authorize, :set_locale, :except => :options
  before_filter :add_cors_header, :only => :options

  layout :choose_layout

  cattr_accessor :applications
  @@applications=HashWithIndifferentAccess.new

  def current_app
    @current_app ||= (find_current_app || @current_app = App.first)
  end

  def phin_oid_prefix
    "#{PHIN_PARTNER_OID}.#{PHIN_APP_OID}.#{PHIN_ENV_OID}"
  end

  def admin_or_self_required(var = :id)
    ensure_admin_or_self(params[var])
  end

  def ensure_admin_or_self(user_id)
    unless User.find(user_id).editable_by?(current_user)
      respond_to do |format|
        format.html {
          flash[:error] = "That resource does not exist or you do not have access to it."
          redirect_to root_path
        }
        format.json { render :json => {:flash => "Permission denied.", :type => :error} }
      end
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
        if request.format.json? 
          false
        else
          "ext_panel"
        end
      else
        "application"
      end
    else
      "non_application"
    end
  end

  #rescue_from Exception, :with => :render_error
  #rescue_from ActionController::Forbidden, :with => :render_password_error
  
  protected

  def change_include_root
    @original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
  end

  def change_include_root_back
    ActiveRecord::Base.include_root_in_json = @original_included_root
  end

  def folder_or_inbox_path(document)
    document.folder ? folder_documents_path(document.folder) : folder_inbox_path
  end
# 
  # def login_required
    # store_location
    # unless signed_in?
      # respond_to do |format|
        # format.html{ redirect_to sign_in_path }
        # format.ext{ redirect_to sign_in_path }
        # format.json{ redirect_to sign_in_path }
        # format.iphone do
          # headers["Access-Control-Allow-Origin"] = "*"
          # render :json => ['SESSION' => 'EXPIRED']
        # end
      # end
      # false
    # end
  # end

  def authorize
    flash.keep unless signed_in?
    super
  end

  def admin_required
    unless current_user.role_memberships.where(:role_id => (Role.admins | Role.superadmins | [Role.sysadmin]).map(&:id)).count > 0
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

  def super_admin_required
    unless current_user.role_memberships.count(:conditions => {:role_id => (Role.superadmins).map(&:id) }) > 0
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
  
  def super_admin_in_texas_required
    return true if current_user.is_sysadmin?
    unless current_user.role_memberships.count(:conditions => {:role_id => Role.superadmins.map(&:id), :jurisdiction_id => Jurisdiction.find_by_name("Texas") }) > 0
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

  def sys_admin_required
    unless current_user.role_memberships.where(:role_id => Role.sysadmin).count > 0
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
            format.json {render :json => {:success => false, :message => "You are not authorized to view this page"}, :status => 401}
        end
      else
        flash[:error] = "You are not authorized to view this page."
        redirect_to root_path
      end
      false
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

private

  # This makes #present always pass set the current_user on the presenter
  # if the presenter accepts :current_user.
  def present_with_current_user(*args)
    present_without_current_user(*args).tap do |presenter|
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

  def find_current_app
    full_domain = (request.subdomains + [request.domain]).compact.join('.')
    query_string = request.domain.blank? ? "is_default = true" : "#{request.subdomains.blank? ? '' : 'name IN (:subdomains) OR'} domains LIKE :full_domain OR is_default = true"
    App.where(query_string, subdomains: request.subdomains, full_domain: "%#{full_domain}%").order("is_default ASC").first
  end

end
