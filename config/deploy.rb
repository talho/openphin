require 'vendor/plugins/thinking-sphinx/lib/thinking_sphinx/deploy/capistrano'
load 'lib/testjour.rb'
load 'lib/deploy_app.rb'
load 'lib/deploy_jobs.rb'

set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"
set :rails_env, 'production'
set :scm, :git  # override default of subversion
set :branch, 'noplugins2'
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

# Unicorn configuration
set :unicorn_binary, "~apache/.rvm/gems/ree-1.8.7-2010.02/bin/unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

task :production do
  require 'hoptoad_notifier/capistrano'
  role :app, "txphin.texashan.org"
  role :web, "txphin.texashan.org"
  role :jobs, "jobs.texashan.org"
  role :db,  "jobs.texashan.org", :primary => true
end

task :staging do
  role :app, "talhostaging.talho.org"
  role :web, "talhostaging.talho.org"
  role :jobs, "talhostaging.talho.org"
  role :db,  "talhostaging.talho.org", :primary => true
end
 
# Setup dependencies
before 'deploy', 'backgroundrb:stop'
before 'deploy', 'delayed_job:stop'
before 'deploy', 'sphinx:start_if_not'
after 'deploy:update_code', 'app:phin_plugins'
after 'app:phin_plugins', 'app:symlinks'
after 'app:symlinks', 'app:bundle_install'
before 'deploy:start', 'app:phin_plugins_install'
before 'deploy:restart', 'app:phin_plugins_install'
after "deploy", "deploy:cleanup"
after 'deploy', "sphinx:rebuild"
after 'deploy:cold', "sphinx:rebuild"
after 'sphinx:rebuild', 'backgroundrb:restart'
after 'sphinx:rebuild', 'delayed_job:restart'

namespace :deploy do
  # Overriding the built-in task to add our rollback actions
  task :default, :roles => [:app, :web, :jobs] do
    unless rails_env == "test"
      transaction {
        on_rollback do
          puts "  PERFORMING ROLLBACK, restarting jobs daemons"
          find_and_execute_task("backgroundrb:restart")
          find_and_execute_task("delayed_job:restart")
          puts "  END ROLLBACK"
        end
        update
        restart
      }
    end
  end

  desc "unicorn start"
  task :start, :roles => [:app, :web] do
    run "cd #{release_path}; #{unicorn_binary} --daemonize --env production -c #{unicorn_config}"
  end

  desc "unicorn restart"
  task :restart, :roles => [:app, :web] do 
    begin
      run "kill -s USR2 `cat #{unicorn_pid}`"
    rescue Capistrano::CommandError => e
      puts "Rescue: #{e.class} #{e.message}"
      puts "Rescue: It appears that unicorn is not running, starting ..."
      run "sh #{release_path}/config/kill_server_processes unicorn"
      run "cd #{release_path}; #{unicorn_binary} --daemonize --env production -c #{unicorn_config}"
    end
  end
end

after 'deploy:migrate', :seed
after 'deploy:migrations', :seed
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do 
  run "cd #{current_path}; #{rake} db:seed RAILS_ENV=#{rails_env}"
end

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end

set :pivotal_tracker_project_id, 19881
set :pivotal_tracker_token, '55a509fe5dfcd133b30ee38367acebfa'

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end
