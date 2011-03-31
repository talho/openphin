namespace :firefox do
  task :killall do
    system("for i in `ps -ef | grep firefox | grep -v rake | grep -v grep | awk '{print $2}'`; do kill -9 $i; done")
  end
end

namespace :ruby do
  task :killall do
    system("for i in `ps -ef | grep ruby | grep -v rake | grep -v grep | awk '{print $2}'`; do kill -9 $i; done")
  end
end

namespace :sphinx do
  task :killall do
    system("for i in `ps -ef | grep searchd | grep -v rake | grep -v grep | awk '{print $2}'`; do kill -9 $i; done")
  end
end

namespace :db do
  task :killall => :environment do
    begin
      ActiveRecord::Base.connection.execute("SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE datname='#{ActiveRecord::Base.connection.current_database}'")
    rescue
      ActiveRecord::Base.connection.disconnect!
    end
  end
end
