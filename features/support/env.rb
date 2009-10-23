require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] = "cucumber"
# Sets up the Rails environment for Cucumber
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
  require 'cucumber/rails/world'
  require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
# Cucumber::Rails.use_transactional_fixtures
# Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling
  # (e.g. rescue_action_in_public / rescue_responses / rescue_from)
  Cucumber::Rails::World.use_transactional_fixtures = true
  require 'webrat'

  Webrat.configure do |config|
    config.mode = :rails
  end

  require 'cucumber/rails/rspec'
  require 'webrat/core/matchers'

  require "#{Rails.root}/spec/factories"


  World ActionController::RecordIdentifier

  TS = ThinkingSphinx::Configuration.instance
  ThinkingSphinx.deltas_enabled = true
  ThinkingSphinx.updates_enabled = true
  ThinkingSphinx.suppress_delta_output = true
  
  Before('@sphinx') do
    TS.build
    FileUtils.mkdir_p TS.searchd_file_path
    TS.controller.start
  end

  After('@sphinx') do
    TS.controller.stop
    reset_database!
  end
  
  def without_transactions
    @__cucumber_ar_connection.open_transactions.times do
      @__cucumber_ar_connection.commit_db_transaction
    end
    yield
    @__cucumber_ar_connection.open_transactions.times do
      @__cucumber_ar_connection.begin_db_transaction
    end
  end
  
  def reset_database!
    # http://github.com/bmabey/database_cleaner
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  Before do
    # Clear out PHIN_MS queue
    FileUtils.remove_dir(Agency[:phin_ms_base_path], true)
  end

  Before do
    ActionMailer::Base.deliveries = []
    # load application-wide fixtures
    Dir[File.join(RAILS_ROOT, "features/fixtures", '*.rb')].sort.each { |fixture| load fixture }
  end

end
