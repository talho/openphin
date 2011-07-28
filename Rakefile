# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'hydra'
require 'hydra/tasks'

require 'jslint/tasks'
JSLint.config_path = "config/jslint.yml"

task :build => %w(db:migrate spec cucumber)
task :db => %w(db:migrate db:test:prepare)
task :phin_plugins do
  phin_plugins = YAML.load_file("config/phin_plugins.yml")
  phin_plugins.each { |pp|
    cmds = Array.new
    name = File.basename(pp["url"]).sub(/\.git$/, "")
    branch = pp["branch"] || "master"
    cmds << "git clone #{pp["url"]} --branch #{branch} vendor/plugins/#{name}"
    if pp.has_key?("commit")
      cmds << "cd vendor/plugins/#{name}"
      cmds << "git checkout #{pp["commit"]}"
    end
    sh cmds.join(" && ")
  }
end

Hydra::TestTask.new('hydra' => ['environment']) do |t|
  t.add_files 'features/**/*.feature'
  t.verbose = true
  t.environment = 'cucumber'
end

Hydra::GlobalTask.new('db:killall')

Hydra::GlobalTask.new('db:migrate:reset')

Hydra::GlobalTask.new('firefox:killall')

Hydra::GlobalTask.new('ruby:killall')

Hydra::GlobalTask.new('sphinx:killall')

Hydra::SyncTask.new('hydra:sync')

Hydra::GlobalTask.new('ts:in')
