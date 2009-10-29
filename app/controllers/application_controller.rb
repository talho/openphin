# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include CachingPresenter::InstantiationMethods
  include Clearance::Authentication
  #include ExceptionNotifiable
  helper :all # include all helpers, all the time
  helper_method :toolbar
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :login_required, :set_locale

  layout :choose_layout
  
  cattr_accessor :applications
  @@applications=HashWithIndifferentAccess.new
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def phin_oid_prefix
    "#{PHIN_PARTNER_OID}.#{PHIN_APP_OID}.#{PHIN_ENV_OID}"
  end

  def admin_or_self_required(var = :id)
    unless current_user.role_memberships.detect{ |rm| rm.role == Role.admin || rm.role == Role.superadmin } || current_user.id.to_s == params[var]
      flash[:error] = "That resource does not exist or you do not have access to it."
      redirect_to dashboard_path
      false
    end
  end

  def toolbar
	  self.class.app_toolbar
  end

  protected

  #TODO needs to be moved to rollcall plugin
    def rollcall_required
      unless current_user.role_memberships.detect{ |rm| rm.role == Role.find_by_name('Rollcall')}
        flash[:error] = "You have not been given access to the Rollcall application.  Email your OpenPHIN administrator for help."
        redirect_to about_rollcall_path
        false
      end
    end
  
    def folder_or_inbox_path(document)
      document.folder || documents_path
    end
    
    def login_required
      store_location
      unless signed_in?
        redirect_to sign_in_path 
        false
      end
    end

    def admin_required
      unless current_user.role_memberships.detect{ |rm| rm.role == Role.admin  || rm.role == Role.superadmin }
        flash[:error] = "That resource does not exist or you do not have access to it."
        redirect_to dashboard_path
        false
      end
    end

    def non_public_role_required
      unless current_user.has_non_public_role?
        flash[:error] = "You are not authorized to view this page."
        redirect_to dashboard_path
        false 
      end
    end
    
    def can_view_alert
      alert = Alert.find(params[:id])
      unless !alert.nil? && alert.recipients.include?(current_user)
        flash[:error] = "That resource does not exist or you do not have access to it."
        redirect_to dashboard_path
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
		    @toolbar = "application" unless File.exist?(File.join(Rails.root, 'app', 'views', 'toolbars', "_#{toolbar_partial}.html.erb"))
	    else
		    @toolbar = toolbar
	    end
	    @toolbar	    
    end

    def choose_layout
      if signed_in?
        return "application"
      else
        return "non_application"
      end
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
end