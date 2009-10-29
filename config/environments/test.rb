# Settings specified here will take precedence over those in config/environment.rb

UPLOAD_BASE_URI = "http://localhost:3000"

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
##don't load backgroundrb in test environment'
config.plugins = config.plugin_locators.map do |locator|
  locator.new(self).plugins
end.flatten.map{|p| p.name.to_sym}
config.plugins -= [:backgroundrb]

config.gem 'rspec',       :lib => false,        :version => '>=1.2.9'
config.gem 'rspec-rails', :lib => false,        :version => '>=1.2.9'
config.gem 'webrat',      :lib => false,        :version => '>=0.5.3'
config.gem "thoughtbot-factory_girl",
  :lib    => "factory_girl",
  :source => "http://gems.github.com"


# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql
PHIN_PARTNER_OID="1.3.6.1.4.1.1"
PHIN_APP_OID="1"
PHIN_ENV_OID="3"
PHIN_OID_ROOT="#{PHIN_PARTNER_OID}.#{PHIN_ENV_OID}.#{PHIN_APP_OID}"

