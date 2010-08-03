require 'spec/rake/spectask'

PLUGIN = "vendor/plugins/PLUGIN_NAME"

namespace :spec do
  desc "Run the PLUGIN_NAME spec tests"
  Spec::Rake::SpecTask.new(:PLUGIN_NAME) do |t|
    t.spec_files = FileList["#{PLUGIN}/spec/**/*_spec.rb"]
  end
end
