namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job stop" unless rails_env == "test"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job start" unless rails_env == "test"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/delayed_job restart" unless rails_env == "test"
  end
end

namespace :backgroundrb do
  desc "stop backgroundrb"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/backgroundrb stop" unless rails_env == "test"
  end

  desc "start backgroundrb"
  task :start, :roles => :jobs do
    run "cd #{current_path}; BUNDLE_GEMFILE=#{bundle_gemfile} RAILS_ENV=#{rails_env} bundle exec script/backgroundrb start" unless rails_env == "test"
  end

  desc "restart backgroundrb"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec script/backgroundrb restart" unless rails_env == "test"
  end
end

require 'thinking_sphinx/deploy/capistrano'
namespace :sphinx do
  task :stop, :roles => [:app] do
     run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake thinking_sphinx:stop"
  end
  
  task :symlink_sphinx_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/sphinx #{current_path}/db/sphinx"
  end
  
  task :start, :roles => [:app] do
    symlink_sphinx_indexes
    thinking_sphinx.configure
    thinking_sphinx.start
  end
end