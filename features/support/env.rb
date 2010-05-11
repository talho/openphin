ENV["RAILS_ENV"] = "cucumber"
# Sets up the Rails environment for Cucumber
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  require 'cucumber/rails/world'
  require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
# Cucumber::Rails.use_transactional_fixtures
# Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling
  # (e.g. rescue_action_in_public / rescue_responses / rescue_from)
  Cucumber::Rails::World.use_transactional_fixtures = false
  # If you set this to true, each scenario will run in a database transaction.
  # You can still turn off transactions on a per-scenario basis, simply tagging 
  # a feature or scenario with the @no-txn tag. 
  #
  # If you set this to false, transactions will be off for all scenarios,
  # regardless of whether you use @no-txn or not.

  # If you set this to false, any error raised from within your app will bubble 
  # up to your step definition and out to cucumber unless you catch it somewhere
  # on the way. You can make Rails rescue errors and render error pages on a
  # per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
  #
  # If you set this to true, Rails will rescue all errors and render error
  # pages, more or less in the same way your application would behave in the
  # default production environment. It's not recommended to do this for all
  # of your scenarios, as this makes it hard to discover errors in your application.
  ActionController::Base.allow_rescue = false
  
  require 'webrat'
  require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)
  require 'webrat/core/matchers' 
  Webrat.configure do |config|
    config.mode = :rails
    config.open_error_files = false # Set to true if you want error pages to pop up in the browser
  end
  require 'cucumber/rails/rspec'

  require "#{Rails.root}/spec/factories"


  World ActionController::RecordIdentifier

  ts = ThinkingSphinx::Configuration.instance
  ThinkingSphinx.deltas_enabled = true
  ThinkingSphinx.updates_enabled = true
  ThinkingSphinx.suppress_delta_output = true
  ts.build
  FileUtils.mkdir_p ts.searchd_file_path
  ts.controller.index
  ts.controller.start
  at_exit do
    ts.controller.stop
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  Before do
    # Clear out PHIN_MS queue
    FileUtils.remove_dir(Agency[:phin_ms_base_path], true)
  end

# http://github.com/bmabey/database_cleaner
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  Before do
    ActionMailer::Base.deliveries = []
    Service::Blackberry.instance_eval do
      Service::Blackberry.clearDeliveries
    end

    Service::Phone.instance_eval do
      Service::Phone.clearDeliveries
    end

    Service::SMS.instance_eval do
      Service::SMS.clearDeliveries
    end

    Service::Email.instance_eval do
      Service::Email.clearDeliveries
    end

    DatabaseCleaner.clean
    # load application-wide fixtures
    Dir[File.join(RAILS_ROOT, "features/fixtures", '*.rb')].sort.each { |fixture| load fixture }

    # Re-generate the index before each Scenario
    ts = ThinkingSphinx::Configuration.instance
    ThinkingSphinx.deltas_enabled = true
    ThinkingSphinx.updates_enabled = true
    ThinkingSphinx.suppress_delta_output = true
    ts.build
    ts.controller.index
  end
end

