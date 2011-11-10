require "rspec/core/rake_task"

PLUGIN = "vendor/plugins/<%= file_name %>"

namespace :spec do
  desc "Run the <%= class_name %> spec tests"  
  RSpec::Core::RakeTask.new(:<%= file_name %>) do |spec|
    spec.pattern = "#{PLUGIN}/spec/**/*_spec.rb"
  end
end
