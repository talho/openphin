require 'vendor/plugins/thinking-sphinx/lib/thinking_sphinx/deploy/capistrano'
load 'lib/testjour.rb'

set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"
set :rails_env, 'production'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# Unicorn configuration
set :unicorn_binary, "~apache/.rvm/gems/ree-1.8.7-2010.02/bin/unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
RAILS_ENV="production"
task :production do
	role :app, "newtxphin.texashan.org"
	role :web, "newtxphin.texashan.org"
	role :jobs, "newtxphin.texashan.org"
	role :db,  "newtxphin.texashan.org", :primary => true
end

task :staging do
	role :app, "192.168.30.96"
	role :web, "192.168.30.96"
	role :jobs, "192.168.30.97"
	role :db,  "192.168.30.97", :primary => true
end

set :scm, :git
set :branch, 'rollcall_plugin'
set :use_sudo, false
set :user, 'apache'
set :git_enable_submodules, true
set :ssh_options, {:forward_agent => true}
set :deploy_via, :remote_cache
 

after 'deploy:update_code', 'deploy:symlink_configs'
after 'deploy:symlink_configs', 'deploy:bundle_install'
after "deploy", "deploy:cleanup"
namespace :deploy do
  # Overriding the built-in task to add our rollback actions
  task :default, :roles => [:app, :web, :jobs] do
  #  transaction {
  #    on_rollback do
  #      # this rollback will fire if this are any tasks after it fail
  #      puts "  PERFORMING ROLLBACK"
  #      find_and_execute_task("backgroundrb:restart")
  #      find_and_execute_task("delayed_job:restart")
  #      puts "  END ROLLBACK"
  #    end
  #  }
    update
    restart
  end

  desc "we need a database. this helps with that."
  task :symlink_configs, :roles => [:app, :web, :jobs] do 
    rails_env = fetch(:rails_env, RAILS_ENV)
    run "ln -fs #{shared_path}/#{RAILS_ENV}.sqlite3 #{release_path}/db/#{RAILS_ENV}.sqlite3"
    run "ln -fs #{shared_path}/smtp.rb #{release_path}/config/initializers/smtp.rb"
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/sphinx #{release_path}/db/sphinx"
    run "ln -fs #{shared_path}/backgroundrb.yml #{release_path}/config/backgroundrb.yml"
    run "ln -fs #{shared_path}/swn.yml #{release_path}/config/swn.yml"
    run "ln -fs #{shared_path}/email.yml #{release_path}/config/email.yml"
    run "ln -fs #{shared_path}/phone.yml #{release_path}/config/phone.yml"
    run "ln -fs #{shared_path}/system.yml #{release_path}/config/system.yml"
    run "ln -fs #{shared_path}/phin_ms_queues #{release_path}/tmp/phin_ms_queues"
    run "ln -fs #{shared_path}/rollcall #{release_path}/tmp/rollcall"
    run "ln -fs #{shared_path}/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -fs #{shared_path}/testjour.yml #{release_path}/config/testjour.yml"
    run "ln -fs #{shared_path}/tutorials #{release_path}/public/tutorials"
    run "ln -fs #{shared_path}/attachments #{release_path}/attachments"
    # for the rollcall plugin
    run "ln -fs #{release_path}/vendor/plugins/rollcall/lib/workers #{release_path}/lib/workers/rollcall"
    run "ln -fs #{release_path}/spec/spec_helper.rb #{release_path}/vendor/plugins/rollcall/spec/spec_helper.rb"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/javascript #{release_path}/public/javascripts/rollcall"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/stylesheets #{release_path}/public/stylesheets/rollcall"

    run "cd #{release_path}/vendor/plugins/rollcall; git submodule update -i"

    run "ln -fs #{shared_path}/vendor/cache #{release_path}/vendor/cache"
    if rails_env == 'test'|| rails_env == 'development' || rails_env == "cucumber"
      FileUtils.cp("config/backgroundrb.yml.example", "config/backgroundrb.yml") unless File.exist?("config/backgroundrb.yml")
      FileUtils.cp("config/system.yml.example", "config/system.yml") unless File.exist?("config/system.yml")
      #FileUtils.cp("config/phone.yml.example", "config/phone.yml") unless File.exist?("config/phone.yml")
      #FileUtils.cp("config/swn.yml.example", "config/swn.yml") unless File.exist?("config/swn.yml")
    end
  end

  desc "run bundle install for gem dependencies"
  task :bundle_install, :roles => [:app, :web, :jobs] do 
    run "cd #{release_path}; bundle install --without=test --without=cucumber --without=tools"
  end

  desc "unicorn restart"
  task :restart, :roles => [:app, :web, :jobs] do 
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

after 'deploy:migrations', :seed
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do 
  rails_env = fetch(:rails_env, RAILS_ENV)
  run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
end

namespace :sphinx do
  desc "start sphinx if not running"
  task :start_if_not, :roles => :jobs do
    cmd = "cd #{current_path};"
    cmd += '[[ -z "$(ps -ef | grep sphinx | grep -v grep)" ]] &&'
    cmd += "rake ts:index RAILS_ENV=#{rails_env} && "
    cmd += "rake ts:start RAILS_ENV=#{rails_env}"
  end

  desc "stop, index and then start sphinx"
  task :rebuild, :roles => :jobs do
    begin
      run "cd #{previous_release}; rake ts:stop RAILS_ENV=#{rails_env}"
    rescue Capistrano::CommandError => e
      puts "Rescue: #{e.class} #{e.message}"
      puts "Rescue: sphinx stop failed, ignoring ..."
      run "cd #{current_path}; rake ts:index RAILS_ENV=#{rails_env}"
      run "cd #{current_path}; rake ts:start RAILS_ENV=#{rails_env}"
    end
  end
end

namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} restart"
  end
end

namespace :backgroundrb do
  desc "stop backgroundrb"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb stop" unless rails_env == "test"
  end

  desc "start backgroundrb"
  task :start, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb start" unless rails_env == "test"
  end

  desc "restart backgroundrb"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb restart" unless rails_env == "test"
  end
end

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end

set :pivotal_tracker_project_id, 19881
set :pivotal_tracker_token, '55a509fe5dfcd133b30ee38367acebfa'

before 'deploy', 'backgroundrb:stop'
before 'deploy', 'delayed_job:stop'
before 'deploy', 'sphinx:start_if_not'
after 'deploy', "sphinx:rebuild"
after 'sphinx:rebuild', 'backgroundrb:restart'
after 'sphinx:rebuild', 'delayed_job:restart'


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
