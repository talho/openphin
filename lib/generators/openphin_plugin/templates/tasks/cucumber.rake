require 'cucumber/rake/task'

ENV["RAILS_ENV"] ||= "cucumber"

namespace :cucumber do
  desc = "PLUGIN_NAME plugin, add any cmd args after --"
  Cucumber::Rake::Task.new({:PLUGIN_NAME => 'db:test:prepare'}, desc) do |t|
    t.cucumber_opts = "-r features " +
                      "-r vendor/plugins/PLUGIN_NAME/spec/factories.rb " +
                      "-r vendor/plugins/PLUGIN_NAME/features/step_definitions " +
                      " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                      # add all PLUGIN_NAME features if none are passed in
                      (ARGV.grep(/^vendor/).empty? ? "vendor/plugins/PLUGIN_NAME/features" : "")
    t.fork = true
    t.profile = 'default'
  end
end
