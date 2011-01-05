require 'pp'

class OpenphinPluginGenerator < Rails::Generator::NamedBase
  def manifest
    @project_root = @destination_root
    @destination_root += "/vendor/plugins/#{file_name}"

    record do |m|
      m.directory "app"
      m.directory "app/controllers"
      m.directory "app/helpers"
      m.directory "app/models"
      m.directory "app/views"
      m.directory "config"
      m.directory "db"
      m.directory "db/fixtures"
      m.directory "db/migrate"
      m.directory "features"
      m.directory "features/step_definitions"
      m.directory "lib"
      m.directory "lib/models"
      m.directory "lib/workers"
      m.directory "public/javascripts"
      m.directory "public/stylesheets"
      m.directory "spec"
      m.directory "tasks"
      m.directory "vendor/plugins"

      m.template "README", "README"
      m.template "MIT-LICENSE", "MIT-LICENSE"
      m.template "Rakefile", "Rakefile"
      m.template "init.rb", "init.rb"
      m.template "install.rb", "install.rb"
      m.template "uninstall.rb", "uninstall.rb"
      m.template "config/routes.rb", "config/routes.rb"
      m.template "gitignore", ".gitignore"
      m.template "lib/PLUGIN.rb", "lib/#{file_name}.rb"
      m.template "spec/factories.rb", "spec/factories.rb"
      m.template "tasks/PLUGIN_tasks.rake", "tasks/#{file_name}_tasks.rake"
      m.template "tasks/cucumber.rake", "tasks/cucumber.rake"
      m.template "tasks/rspec.rake", "tasks/rspec.rake"
      m.readme "../../../../vendor/plugins/#{file_name}/README"

    end
  end

  def after_generate
    require destination_path("install.rb")
  end
end
