# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = 'test'
is_plugin = File.dirname(__FILE__).include? "vendor/plugins"
unless defined?(Rails.root)
  if is_plugin
    require File.dirname(__FILE__) + "/../../../../config/environment"
    require File.dirname(__FILE__) + "/../spec/factories"
  else
    require File.dirname(__FILE__) + "/../config/environment"
    Dir[File.dirname(__FILE__) + "/../**{,/*/**}/*/spec/factories.rb"].each{ |f| require f }
  end
end
require 'spec/autorun'
require 'spec/rails'
require "webrat"
#require "capybara/rspec"

if is_plugin
  Dir[File.dirname(__FILE__) + '/../../../../spec/spec_helpers/**/*.rb'].each{ |f| require f }
else
  Dir[File.dirname(__FILE__) + '/spec_helpers/**/*.rb'].each{ |f| require f }
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = File.dirname(__FILE__) + '/../spec/fixtures/'

  config.include Webrat::Matchers, :type => [:view]
  config.extend SpecHelpers::ModelMacros, :type => [:model]
  config.extend SpecHelpers::ControllerMacros, :type => [:controller, :integration]
  config.include SpecHelpers::ControllerHelpers, :type => [:controller, :integration]
  config.include CachingPresenter::InstantiationMethods, :type => [:view]
end
