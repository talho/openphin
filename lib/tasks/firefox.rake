namespace :firefox do
  task :killall do
    system("for i in `ps -ef | grep firefox | grep -v rake | awk '{print $2}'`; do kill -9 $i; done")
  end
end

namespace :ruby do
  task :killall do
    system("for i in `ps -ef | grep ruby | grep -v rake | awk '{print $2}'`; do kill -9 $i; done")
  end
end