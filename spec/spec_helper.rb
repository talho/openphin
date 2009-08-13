# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

Dir[File.dirname(__FILE__) + '/spec_helpers/**/*.rb'].each{ |f| require f }

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  config.include Webrat::Matchers, :type => [:view]
  config.extend SpecHelpers::ModelMacros, :type => [:model]
  config.extend SpecHelpers::ControllerMacros, :type => [:controller]
  config.include SpecHelpers::ControllerHelpers, :type => [:controller]
  config.include CachingPresenter::InstantiationMethods, :type => [:view]
end