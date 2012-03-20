# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'initializers', 'utilities')

HOST = "phin.talho.org"
DOMAIN = "talho.org"

# see: http://www.redmine.org/issues/7516
if Gem::VERSION >= '1.3.6'
  module Rails
    class GemDependency
      def requirement
      r = super
      (r == Gem::Requirement.default) ? nil : r
      end
    end
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.autoload_paths += %W(
    #{Rails.root}/app/mailers
    #{Rails.root}/app/observers
    #{Rails.root}/app/presenters
    #{Rails.root}/app/xml
  ) 

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  config.reload_plugins = true if RAILS_ENV == 'development'

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = :role_request_observer, :organization_membership_request_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Central Time (US & Canada)'
  
  config.action_mailer.default_url_options = { :host => HOST }

  config.middleware.use 'Rack::RawUpload', :paths => ["/documents.*"]
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
ActionController::Base.cache_store = :file_store, "#{Rails.root}/tmp/cache"
ActiveRecord::Base.lock_optimistically = true

require 'yaml' # a fix for delayed_job which is built for the semi-deprecated syck rather than the replacement psyck
YAML::ENGINE.yamler = "syck"

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:standard => "%B %d, %Y")
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:standard => "%B %d, %Y %I:%M %p")

require 'happymapper'
#require 'httparty'

# suppress Sphinx indexer tool output into log files
ThinkingSphinx.suppress_delta_output = true
