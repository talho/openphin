namespace :sphinx do
  desc "start sphinx if not running"
  task :start_if_not, :roles => :jobs do
    unless rails_env == "test"
      # only start if no sphinx process are running
      cmd = "cd #{current_path};"
      cmd += '[[ -n "$(ps -ef | grep sphinx | grep -v grep)" ]] || '
      cmd += "(RAILS_ENV=#{rails_env} bundle exec rake ts:index && "
      cmd += "RAILS_ENV=#{rails_env} bundle exec rake ts:start)"
      run cmd
    end
  end

  desc "stop, index and then start sphinx"
  task :rebuild, :roles => :jobs do
    unless rails_env == "test"
      begin
        run "cd #{previous_release}; RAILS_ENV=#{rails_env} bundle exec rake ts:stop"
      rescue Capistrano::CommandError => e
        puts "Rescue: #{e.class} #{e.message}"
        puts "Rescue: sphinx stop failed, ignoring ..."
      end
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake ts:index"
      run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake ts:start"
    end
  end
end

namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop" unless rails_env == "test"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start" unless rails_env == "test"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart" unless rails_env == "test"
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
