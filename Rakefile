# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
#$: << File.dirname(__FILE__)

require File.expand_path('../config/application', __FILE__)

Openphin::Application.load_tasks
# 
# require 'rake'
# require 'rake/testtask'
# require 'rdoc/task'
# 
# require 'tasks/rails'
# # require 'hydra'
# # require 'hydra/tasks'
# 
# begin
  # require 'jslint/tasks'
  # JSLint.config_path = "config/jslint.yml"
# rescue LoadError
# end
# 
# task :build => %w(db:migrate spec cucumber)
# task :db => %w(db:migrate db:test:prepare)
# 
# begin
  # require 'thinking_sphinx/tasks'
# rescue LoadError
  # puts "You can't load Thinking Sphinx tasks unless the thinking-sphinx gem is installed."
# end
# 
# begin
  # require 'delayed/tasks'
# rescue LoadError
   # STDERR.puts "Run `rake gems:install` to install delayed_job"
# end
