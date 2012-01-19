begin
  require 'cucumber/rake/task'

  ENV["RAILS_ENV"] ||= "cucumber"

  namespace :cucumber do
    desc = "<%= class_name %> plugin, add any cmd args after --"
    Cucumber::Rake::Task.new({:<%= singular_name %> => 'db:test:prepare'}, desc) do |t|
      t.cucumber_opts = "-r features " +
                        "-r vendor/plugins/<%= file_name %>/spec/factories.rb " +
                        "-r vendor/plugins/<%= file_name %>/features/step_definitions " +
                        " #{ARGV[1..-1].join(" ") if ARGV[1..-1]}" +
                        # add all <%= class_name %> features if none are passed in
                        (ARGV.grep(/^vendor/).empty? ? "vendor/plugins/<%= file_name %>/features" : "")
      t.fork = true
      t.profile = 'default'
    end
  end
rescue LoadError
  # to catch if cucmber is not installed, as in production
end
