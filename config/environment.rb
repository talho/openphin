# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'initializers', 'utilities')

HOST = "www.txphin.org"
DOMAIN = "txphin.org"

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.load_paths += %W(
    #{Rails.root}/app/mailers
    #{Rails.root}/app/observers
    #{Rails.root}/app/presenters
    #{Rails.root}/app/xml
    #{Rails.root}/app/presenters
  ) 

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = :role_request_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Central Time (US & Canada)'
  
  config.action_mailer.default_url_options = { :host => HOST }  

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  #TODO: add these back in later
#  config.gem "libxslt-ruby"
#  config.gem "libxml-ruby"
  config.gem "hpricot", :version => "=0.6"
  
  config.gem 'thoughtbot-clearance',
    :lib     => 'clearance', 
    :source  => 'http://gems.github.com', 
    :version => '0.6.9'
  config.gem 'thoughtbot-paperclip',
    :lib     => 'paperclip', 
    :source  => 'http://gems.github.com', 
    :version => '2.3.0'
  config.gem 'fastercsv', :version => '1.5.0'
  config.gem 'httparty',
    :lib => 'httparty',
    :version => '0.4.4'
  config.gem 'chronic',
    :source => 'http://gems.github.com',
    :version => '0.2.3'
  config.gem 'packet',
    :source => 'http://gems.github.com',
    :version => '0.1.15'
  config.gem 'validatable', :version => '1.6.7'
  config.gem 'bullet', :source => 'http://gemcutter.org'
  config.gem 'ruby-growl', :source => 'http://gemcutter.org'
end

PHINMS_INCOMING=File.join(Rails.root,"tmp","phin_ms_queues", 'senderincoming')
PHINMS_ARCHIVE=File.join(Rails.root,"tmp","phin_ms_queues", 'archive')
PHINMS_ERROR=File.join(Rails.root,"tmp","phin_ms_queues", 'error')
Dir.ensure_exists(PHINMS_INCOMING)
Dir.ensure_exists(PHINMS_ARCHIVE)
Dir.ensure_exists(PHINMS_ERROR)

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:standard => "%B %d, %Y")
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:standard => "%B %d, %Y %I:%M %p")

require 'happymapper'
#require 'httparty'