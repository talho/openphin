# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'cucumber/rails/rspec'
require 'cucumber/rails/world'
require 'cucumber/rails/active_record'
require 'cucumber/web/tableish'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
#require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript

require "#{Rails.root}/spec/factories"
require 'spec/mocks'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

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

# If you set this to true, each scenario will run in a database transaction.
# You can still turn off transactions on a per-scenario basis, simply tagging 
# a feature or scenario with the @no-txn tag. If you are using Capybara,
# tagging with @culerity or @javascript will also turn transactions off.
#
# If you set this to false, transactions will be off for all scenarios,
# regardless of whether you use @no-txn or not.
#
# Beware that turning transactions off will leave data in your database 
# after each scenario, which can lead to hard-to-debug failures in 
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
Cucumber::Rails::World.use_transactional_fixtures = false
# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.

Capybara.register_driver :selenium_with_firebug do |app|
  Capybara::Driver::Selenium
  profile = Selenium::WebDriver::Firefox::Profile.new
  if File.exists?("#{Rails.root}/features/support/firebug.xpi")
    profile['extensions.firebug.currentVersion'] = '100.100.100'
    profile['extensions.firebug.console.enableSites'] = 'true'
    profile['extensions.firebug.script.enableSites'] = 'true'
    profile['extensions.firebug.net.enableSites'] = 'true'
    profile.add_extension("#{Rails.root}/features/support/firebug.xpi")

    Capybara::Driver::Selenium.new(app, { :browser => :firefox, :profile => profile })
  else
    Capybara::Driver::Selenium.new(app, { :browser => :firefox })
  end
end

Capybara.default_driver = :selenium_with_firebug
#if File.exists?("#{Rails.root}/firebug.xpi")
#  profile = Selenium::WebDriver::Firefox::Profile.new
#  profile['extensions.firebug.currentVersion'] = '100.100.100'
#  profile.add_extension("#{Rails.root}/firebug.xpi")
#
#  Selenium::WebDriver.for :firefox, :profile => profile
#end

Spork.prefork do
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
 Before do
   # Clear out PHIN_MS queue
   FileUtils.remove_dir(Agency[:phin_ms_base_path], true)
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

    # load application-wide fixtures
    Dir[File.join(RAILS_ROOT, "features/fixtures", '*.rb')].sort.each { |fixture| load fixture }

    # Re-generate the index before each Scenario
    ts = ThinkingSphinx::Configuration.instance
    ThinkingSphinx.deltas_enabled = true
    ThinkingSphinx.updates_enabled = true
    ThinkingSphinx.suppress_delta_output = true
    ts.build
    ts.controller.index

    $rspec_mocks ||= Spec::Mocks::Space.new
  end

  if defined?(ActiveRecord::Base)
    begin
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
      rescue LoadError => ignore_if_database_cleaner_not_present
      end
    end

    After do
      begin
        visit '/sign_out'
        unset_current_user
        $rspec_mocks.verify_all
      ensure
        $rspec_mocks.reset_all
      end
    end
  end
