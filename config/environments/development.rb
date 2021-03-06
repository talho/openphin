Openphin::Application.configure do
  require 'ipaddr'

  # Settings specified here will take precedence over those in config/environment.rb

  UPLOAD_BASE_URI = "http://localhost:3000"
  HOST = 'localhost:3000'

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.active_support.deprecation = :stderr

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = false

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.reload_plugins                                = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => HOST }

  #config.reload_plugins = true
  config.action_dispatch.best_standards_support = :builtin

  config.logger = Logger.new(Rails.root.join("log",Rails.env + ".log"), 3, 10 * 1024**2)

  config.assets.compress = false
  config.assets.debug = true

  PHIN_PARTNER_OID="2.16.840.1.114222.4.3.2.2.3.770"
  PHIN_APP_OID="1"
  PHIN_ENV_OID="2"
  PHIN_OID_ROOT="#{PHIN_PARTNER_OID}.#{PHIN_ENV_OID}.#{PHIN_APP_OID}"

  ENV["DELAYED_JOB_OVERRIDE"] = "1"

  config.middleware.use ::Rack::PerftoolsProfiler, :default_printer => 'gif', :bundler => true, :mode => :walltime

  config.dev_tweaks.autoload_rules do
    keep :all

    skip '/favicon.ico'
    skip :assets
    keep :xhr
    keep :forced
  end
end
