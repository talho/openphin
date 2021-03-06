require 'thinking_sphinx/deploy/capistrano'
#load 'lib/testjour.rb'
load 'lib/deploy_app.rb'
load 'lib/deploy_jobs.rb'

set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"
set :rails_env, 'production'
set :scm, :git  # override default of subversion
set :branch, 'master'
set :use_sudo, false
set :user, 'talho'
set :ssh_options, {:forward_agent => true}
set :deploy_via, :remote_cache
set :bundle_gemfile, "Gemfile"
set :normalize_asset_timestamps, false

set :rvm_ruby_string, 'ruby-1.9.3-p194'                     # Or:
require "rvm/capistrano"                               # Load RVM's capistrano plugin.

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, Proc.new { "#{(capture "echo $HOME").delete("\\\n")}/#{application}"}

task :talhojobs do
  set :user, 'apache'
  set :deploy_to, "/var/www/#{application}"
  set :phin_plugins, [:talho, :vms, :rollcall, :facho]
  set :bundle_gemfile, "Gemfile.talho"
  default_environment["BUNDLE_GEMFILE"] = "Gemfile.talho"
  #role :app, "192.168.30.102"
  role :jobs, "192.168.30.102", :primary => true
end

task :talhostaging do
  set :phin_plugins, [:talho, :vms, :rollcall, :facho, :epi]
  set :bundle_gemfile, "Gemfile.talho"
  default_environment["BUNDLE_GEMFILE"] = "Gemfile.talho"
  role :app, "192.168.30.64"
  role :web, "192.168.30.64"
  role :jobs, "192.168.30.64"
  role :db,  "192.168.30.64", :primary => true
end

task :talhoproduction do
  set :phin_plugins, [:talho, :vms, :rollcall, :facho, :epi]
  set :bundle_gemfile, "Gemfile.talho"
  default_environment["BUNDLE_GEMFILE"] = "Gemfile.talho"
  role :app, "192.168.30.62"
  role :web, "192.168.30.62"
  role :jobs, "192.168.30.62"
  role :db,  "192.168.30.62", :primary => true
end

task :talhodemo do
  set :phin_plugins, [:talho, :vms, :rollcall, :facho, :epi]
  set :bundle_gemfile, "Gemfile.talho"
  default_environment["BUNDLE_GEMFILE"] = "Gemfile.talho"
  role :app, "192.168.30.55"
  role :web, "192.168.30.55"
  role :jobs, "192.168.30.55"
  role :db,  "192.168.30.55", :primary => true
end

require 'bundler/capistrano'

# Setup dependencies
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'app:install_requirements'
before 'deploy:setup', 'rvm:install_ruby'
after 'deploy:setup', 'app:install_yml'
after 'deploy:update_code', 'sphinx:stop'
after 'deploy:update_code', 'app:symlinks'
after "deploy:update_code", "deploy:cleanup"
after 'deploy:restart', 'sphinx:start'
after 'deploy:restart', 'backgroundrb:restart'
after 'deploy:restart', 'delayed_job:restart'

# namespace :deploy do
  # # Overriding the built-in task to add our rollback actions
  # task :default, :roles => [:app, :web, :jobs] do
    # unless rails_env == "test"
      # transaction {
        # on_rollback do
          # puts "  PERFORMING ROLLBACK, restarting jobs daemons"
          # find_and_execute_task("backgroundrb:restart")
          # find_and_execute_task("delayed_job:restart")
          # puts "  END ROLLBACK"
        # end
        # update
        # restart
      # }
    # end
  # end
# end

after 'deploy:migrate', :seed
after 'deploy:migrate', 'app:phin_plugins_migrate'
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do
  run "cd #{release_path}; RAILS_ENV=#{rails_env} #{rake} db:seed"
end

# Unicorn configuration
set :unicorn_bin, "unicorn"
set :unicorn_env, rails_env
require 'capistrano-unicorn'

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end

set :pivotal_tracker_project_id, 19881
set :pivotal_tracker_token, '55a509fe5dfcd133b30ee38367acebfa'


        require './config/boot'
        require 'airbrake/capistrano'
