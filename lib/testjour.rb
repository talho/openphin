TestJour_config=Hash.new
TestJour_config.merge! YAML.load_file("config/testjour.yml") if File.exists?("config/testjour.yml")

task :testing do
  role :app, testjour_master
  role :web, testjour_master
  role :db,  testjour_master, :primary => true
  role :jobs, testjour_master
  set :application, "openphin"
  set :repository,  TestJour_config["repository"]
  set :rails_env, 'test'
  set :branch, get_branch

  set :user, TestJour_config["master_user"]
  set :root_path, TestJour_config["root_path"]

  namespace :deploy do
    set :deploy_to, "#{root_path}/#{application}"
    task :migrate do
      run "cd #{current_path}; RAILS_ENV=cucumber rake hydra:sync"
      run "cd #{current_path}; rake hydra:ruby:killall"
      run "cd #{current_path}; RAILS_ENV=cucumber rake db:killall"
      run "cd #{current_path}; RAILS_ENV=cucumber rake hydra:db:migrate:reset"
    end

    task :start, :role => :app do
      run "cd #{current_path}; rake hydra:ruby:killall"
      run "cd #{current_path}; rake hydra:sphinx:killall"
      run "cd #{current_path}; rake hydra:firefox:killall"
      run "cd #{current_path}; RAILS_ENV=cucumber rake hydra:ts:in"
      run "cd #{current_path}; RAILS_ENV=cucumber rake hydra"
    end

    before :cold, :role => :app do
      `git push testjour #{get_branch} -f`
    end
  end

  task :seed, :roles => :db, :only => {:primary => true} do
  end

  before :deploy, :role => :app do
    `git push testjour #{get_branch} -f`
    run "mkdir #{release_path}"
    run "rm -rf #{release_path}/../*"
    run ":> #{shared_path}/log/cucumber.log"
    run ":> #{shared_path}/log/searchd.log"
    run ":> #{shared_path}/log/searchd.query.log"
    run ":> #{shared_path}/log/phone.log"
    run ":> #{shared_path}/log/rollcall.log"
    run ":> #{shared_path}/log/swn.log"
    run ":> #{shared_path}/log/test.log"
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
