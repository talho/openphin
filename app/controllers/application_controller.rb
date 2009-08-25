# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include CachingPresenter::InstantiationMethods
  include Clearance::Authentication
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :login_required
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def phin_oid_prefix
    "#{PHIN_PARTNER_OID}.#{PHIN_APP_OID}.#{PHIN_ENV_OID}"
  end
  
  protected
    def login_required
      store_location
      unless signed_in?
        flash[:error] = "You must sign in to complete that operation."
        redirect_to sign_in_path 
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
    
    def admin_required
      unless current_user.role_memberships.detect{ |rm| rm.role == Role.admin }
        flash[:error] = "That resource does not exist or you do not have access to it."
        redirect_to dashboard_path
        false
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
    if role_requests.has_key?("0") && role_requests["0"]["role_id"].blank?
       role_requests["0"]["role_id"] = Role.public.id
    end
  end
end
