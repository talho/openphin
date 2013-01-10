
#require 'db/migrate/20110314145442_create_my_sql_compatible_functions_for_postgres'

Spork.prefork do
  # Make it act like webrat to make conversion easier
  Capybara.default_selector = :css

  # Deliver exceptions like dev instead of production
  ActionController::Base.allow_rescue = false

  # Use database cleaner so selenium can work.
  Cucumber::Rails::World.use_transactional_fixtures = false

  World ActionController::RecordIdentifier

  Delayed::Worker.delay_jobs = false

  require 'cucumber/thinking_sphinx/external_world'
  Cucumber::ThinkingSphinx::ExternalWorld.new

  #CreateMySqlCompatibleFunctionsForPostgres.up if ActiveRecord::Base.configurations[Rails.env]["adapter"] == "postgresql"

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
    load Rails.root.join 'features/fixtures/apps.rb'
    load Rails.root.join 'features/fixtures/jurisdictions.rb'
    load Rails.root.join 'features/fixtures/roles.rb'
  end

  After do
    begin
      visit '/sign_out'
      unset_current_user

      # We need to clear the mongo collection
      config = YAML::load(File.read(File.join(Rails.root,'config','mongo_database.yml'))).symbolize_keys[Rails.env.to_sym].symbolize_keys
      conn = Mongo::Connection.new(config[:host],config[:port],(config[:options]||{}))
      db = conn.db(config[:database])
      db.authenticate(config[:database],config[:password]) if config[:password]
      db.collection('reports').remove
    ensure
    end
  end
end
