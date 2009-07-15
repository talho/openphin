# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
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
        redirect_to sign_in_path 
        false
      end
    end
end
