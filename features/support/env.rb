7# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.
$: << File.join(File.dirname(__FILE__),'..','..')

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
require 'rspec/mocks'
require File.join(File.dirname(__FILE__),'patches','send_key')

#require 'db/migrate/20110314145442_create_my_sql_compatible_functions_for_postgres'

Capybara.register_driver :selenium_with_firebug do |app|
  if File.exists?("#{Rails.root}/features/support/firebug.xpi")
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['extensions.firebug.currentVersion'] = '100.100.100'
    profile['extensions.firebug.console.enableSites'] = 'true'
    profile['extensions.firebug.script.enableSites'] = 'true'
    profile['extensions.firebug.net.enableSites'] = 'true'
    profile['extensions.firebug.allPagesActivation'] = 'on'
    profile.add_extension("#{Rails.root}/features/support/firebug.xpi")

    Capybara::Selenium::Driver.new(app, { :browser => :firefox, :profile => profile, :resynchronize => true })
  else
    Capybara::Selenium::Driver.new(app, { :browser => :firefox, :resynchronize => true })
  end
end if ENV['HEADLESS'] == 'false' 

Capybara.register_driver :selenium_with_chrome do |app|
  Capybara::Selenium::Driver.new(app, { :browser => :chrome, :resynchronize => true })
end

Spork.prefork do
  # Make it act like webrat to make conversion easier
  Capybara.default_selector = :css
  
  # Deliver exceptions like dev instead of production
  ActionController::Base.allow_rescue = false
  
  # Use database cleaner so selenium can work.
  Cucumber::Rails::World.use_transactional_fixtures = false

  World ActionController::RecordIdentifier

  # ts = ThinkingSphinx::Configuration.instance
  # ThinkingSphinx.deltas_enabled = true
  # ThinkingSphinx.updates_enabled = true
  # ThinkingSphinx.suppress_delta_output = true
  # ts.build
  # FileUtils.mkdir_p ts.searchd_file_path
  # ts.controller.index
  # ts.controller.start
  # at_exit do
    # ts.controller.stop
  # end
  require 'cucumber/thinking_sphinx/external_world'
  Cucumber::ThinkingSphinx::ExternalWorld.new
  
  #CreateMySqlCompatibleFunctionsForPostgres.up if ActiveRecord::Base.configurations[RAILS_ENV]["adapter"] == "postgresql"

  Capybara.default_driver = case ENV['BROWSER']
    when 'chrome' then :selenium_with_chrome
    else ENV['HEADLESS'] == 'false' ? :selenium_with_firebug : :selenium
  end
    
  if defined?(ActiveRecord::Base)
    begin
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
    rescue LoadError => ignore_if_database_cleaner_not_present
    end
  end
  
  if ENV["HEADLESS"] != 'false'
    @headless = Headless.new
    @headless.start
  end
end

Spork.each_run do
  Before do
    ActionMailer::Base.deliveries = []
  
    Service::Swn::Message.instance_eval do
      Service::Swn::Message.clearDeliveries
    end

    # load application-wide fixtures
    Dir[File.join(RAILS_ROOT, "features/fixtures", '*.rb')].sort.each { |fixture| load fixture }

    # Re-generate the index before each Scenario
    # ts = ThinkingSphinx::Configuration.instance
    # ThinkingSphinx.deltas_enabled = true
    # ThinkingSphinx.updates_enabled = true
    # ThinkingSphinx.suppress_delta_output = true
    # ts.build
    # ts.controller.index

    #ActiveRecord::Base.connection.execute("SELECT rebuilt_sequences();") if ActiveRecord::Base.configurations[RAILS_ENV]["adapter"] == "postgresql"

    #$rspec_mocks ||= RSpec::Mocks::Space.new
  end

  After do
    begin
      visit '/sign_out'
      unset_current_user
      #$rspec_mocks.verify_all
    ensure
      #$rspec_mocks.reset_all
    end
  end
end