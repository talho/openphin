require 'spec/rake/spectask'

PLUGIN = "vendor/plugins/<%= file_name %>"

namespace :spec do
  desc "Run the <%= class_name %> spec tests"
  Spec::Rake::SpecTask.new(:<%= file_name %>) do |t|
    t.spec_files = FileList["#{PLUGIN}/spec/**/*_spec.rb"]
  end
end
