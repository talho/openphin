require 'thinking_sphinx/deploy/capistrano'
load 'lib/testjour.rb'
load 'lib/deploy_app.rb'
load 'lib/deploy_jobs.rb'

set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"
set :rails_env, 'production'
set :scm, :git  # override default of subversion
set :branch, 'master'
set :use_sudo, false
set :user, 'apache'
set :git_enable_submodules, true
set :ssh_options, {:forward_agent => true}
set :default_run_options, {:shell => "sh -l"}
set :rake, "bundle exec rake"
set :deploy_via, :remote_cache
set :root_path, "/var/www"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "#{root_path}/#{application}"


task :production do
  role :app, "txphin.texashan.org"
  role :web, "txphin.texashan.org"
  role :jobs, "jobs.texashan.org"
  role :db,  "jobs.texashan.org", :primary => true
end

task :staging do
  set :branch, 'messaging'
  role :app, '192.168.30.97' #"staging.txphin.org"
  role :web, '192.168.30.97' #"staging.txphin.org"
  role :jobs, '192.168.30.97' #"staging.txphin.org"
  role :db, '192.168.30.97', :primary => true #"staging.txphin.org"
end
 
task :talhostaging do
  set :branch, 'messaging'
  role :app, "talhostaging.talho.org"
  role :web, "talhostaging.talho.org"
  role :jobs, "talhostaging.talho.org"
  role :db,  "talhostaging.talho.org", :primary => true
end 

task :talhoapps_production do
  set :branch, 'messaging'
  set :unicorn_binary, "~apache/.rvm/gems/ree-1.8.7-2011.03/bin/unicorn_rails"
  role :app, "talhoapps.talho.org"
  role :web, "talhoapps.talho.org"
  role :jobs, "talhoapps.talho.org"
  role :db,  "talhoapps.talho.org", :primary => true  
end

require 'bundler/capistrano'

# Setup dependencies
before 'deploy:update_code', 'sphinx:stop'
after 'deploy:update_code', 'app:phin_plugins'
after 'deploy:update_code', 'app:symlinks'
after "deploy:update_code", "deploy:cleanup"
after 'deploy:symlink', 'app:phin_plugins_install'
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
set :unicorn_bin, "unicorn_rails"
set :unicorn_env, rails_env
require 'capistrano-unicorn'

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end

set :pivotal_tracker_project_id, 19881
set :pivotal_tracker_token, '55a509fe5dfcd133b30ee38367acebfa'

