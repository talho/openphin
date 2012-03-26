Openphin::Application.configure do
  # Edit at your own peril - it's recommended to regenerate this file
  # in the future when you upgrade to a newer version of Cucumber.
  
  # IMPORTANT: Setting config.cache_classes to false is known to
  # break Cucumber's use_transactional_fixtures method.
  # For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
  config.cache_classes = true
  
  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true
  
  # Show full error reports and disable caching
  config.action_controller.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  
  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false
  
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { :host => HOST }
  
  config.plugins = config.plugin_locators.map do |locator|
    locator.new(self).plugins
  end.flatten.map{|p| p.name.to_sym}
  config.plugins -= [:backgroundrb]
  
  PHIN_PARTNER_OID="1.3.6.1.4.1.1"
  PHIN_APP_OID="1"
  PHIN_ENV_OID="3"
  PHIN_OID_ROOT="#{PHIN_PARTNER_OID}.#{PHIN_ENV_OID}.#{PHIN_APP_OID}"
  UPLOAD_BASE_URI = "http://localhost:3000"
  HOST = 'localhost:3000'
end