Openphin::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb
  
  UPLOAD_BASE_URI = "https://phin.talho.org"
  HOST = 'phin.talho.org'
  
  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true
  config.action_view.cache_template_loading            = true
  
  # See everything in the log (default is :info)
  # config.log_level = :debug
  
  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"), 3, 10 * 1024**2)
  
  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  
  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  
  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => HOST }
  
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  # Enable threaded mode
  # config.threadsafe!
  PHIN_PARTNER_OID="2.16.840.1.114222.4.3.2.2.3.770"
  PHIN_APP_OID="1"
  PHIN_ENV_OID="1"
  PHIN_OID_ROOT="#{PHIN_PARTNER_OID}.#{PHIN_ENV_OID}.#{PHIN_APP_OID}"
end