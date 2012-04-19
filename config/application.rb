require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Openphin
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W(
      #{Rails.root.to_s}/app/mailers
      #{Rails.root.to_s}/app/observers
      #{Rails.root.to_s}/app/presenters
      #{Rails.root.to_s}/app/xml
    ) 
  
    
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    config.reload_plugins = true if Rails.env == 'development'
  
    config.filter_parameters += [:password, :confirm_password]
    
    # Activate observers that should always be running
    config.active_record.observers = :role_request_observer, :organization_membership_request_observer
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.time_zone = 'Central Time (US & Canada)'
      
    config.middleware.use 'Rack::RawUpload', :paths => ["/documents.*"]
    
    config.assets.enabled = true
    config.assets.version = '1.0'
  end
end
