task :testing do
  role :app, testjour_master
  role :web, testjour_master
  role :db,  testjour_master, :primary => true
  set :application, "openphin"
  set :repository,  "ssh://root@testmaster.texashan.org/root/openphin.git"
  set :rails_env, 'test'
  set :branch, get_branch

  set :user, 'root'
  set :deploy_to, "/root/#{application}"

end

before :deploy, :role => :app do
  `git stash`
  `git push testjour #{get_branch}`
  `git stash apply`  
end

after :deploy, :role => :app do
  #run "cd #{current_path}; rake db:migrate:reset"
  #run "cd #{current_path}; mysqldump -n -d openphin_development > db/development_structure.sql"

  #run "cd #{current_path}; testjour #{get_slaves} --max-local-slaves=1 --create-mysql-db --mysql-db-name=openphin_test #{get_features}"
end

def get_branch
  `git branch`[/$\s+\*.+/].strip[2..-1]
end

def testjour_master
  return "testmaster.texashan.org"
end

def get_features
  begin
    features
  rescue
    "./features"
  end
end

def get_slaves
  "--on=testjour://testslave1.texashan.org/root/openphin/current/ --on=testjour://testslave2.texashan.org/root/openphin/current/ --on=testjour://testslave3.texashan.org/root/openphin/current/ --on=testjour://testslave4.texashan.org/root/openphin/current/ --on=testjour://testslave5.texashan.org/root/openphin/current/ --on=testjour://testslave6.texashan.org/root/openphin/current/ --on=testjour://testslave7.texashan.org/root/openphin/current/"
end