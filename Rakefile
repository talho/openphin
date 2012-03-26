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
# task :phin_plugins do
  # phin_plugins = YAML.load_file("config/phin_plugins.yml")
  # phin_plugins.each do |pp|
    # cmds = Array.new
    # name = File.basename(pp["url"]).sub(/\.git$/, "")
    # branch = pp["branch"] || "master"
#     
    # unless File.exists?("vendor/plugins/#{name}")
      # cmds << "git clone #{pp["url"]} --branch #{branch} vendor/plugins/#{name}"
    # end
    # cmds << "cd vendor/plugins/#{name}"
    # if pp.has_key?("commit")
      # cmds << "git checkout #{pp["commit"]}"
    # elsif File.exists?("vendor/plugins/#{name}")
      # cmds << "git checkout #{branch}"
      # cmds << "git pull"
    # end
    # sh cmds.join(" && ")
  # end
# end
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
