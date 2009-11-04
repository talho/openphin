TestJour_config=Hash.new
TestJour_config.merge! YAML.load_file("config/testjour.yml") if File.exists?("config/testjour.yml")

task :testing do
  role :app, testjour_master
  role :web, testjour_master
  role :db,  testjour_master, :primary => true
  set :application, "openphin"
  set :repository,  TestJour_config["repository"]
  set :rails_env, 'test'
  set :branch, get_branch

  set :user, TestJour_config["master_user"]
  set :deploy_to, "#{TestJour_config["root_path"]}/#{application}"

  before :deploy, :role => :app do
    `git push testjour #{get_branch}`
  end

  after :deploy, :role => :app do
    begin
      if migrations
        run "cd #{current_path}; rake db:migrate:reset"
        run "cd #{current_path}; mysqldump#{TestJour_config["dbusername"] ? " -u " + TestJour_config["dbusername"] : ""}#{TestJour_config["dbpassword"] ? " --password=" + TestJour_config["dbpassword"] : ""} -n -d openphin_development > #{shared_path}/development_structure.sql"
      end
    rescue
    end
    run "/bin/cp #{shared_path}/development_structure.sql #{release_path}/db/development_structure.sql"

    run "cd #{current_path}; testjour #{get_slaves} --max-local-slaves=1 --create-mysql-db --mysql-db-name=openphin_test #{get_features}"
  end
end

def get_branch
  `git branch` =~ /^\*.(.*)/
  $1
end

def testjour_master
  TestJour_config["master"]
end

def get_features
  begin
    features
  rescue
    "./features"
  end
end

def get_slaves
  TestJour_config["slaves"].split(',').map{|slave| "--on=testjour://#{slave}/#{TestJour_config['root_path']}/#{application}/current/ "}.to_s.strip if TestJour_config["slaves"]
end