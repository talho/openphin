require 'pp'

class OpenphinPluginGenerator < Rails::Generator::Base
  def manifest
    @project_root = @destination_root
    @destination_root += "/vendor/plugins/#{args[0]}"

    record do |m|
      m.instance_variable_set(:@pname, args[0]) 
      def m.install_with_expand(rel_src, rel_dest = rel_src, file_options = {})
        file(rel_src, rel_dest, file_options) {|f|
          contents = f.read
          contents.gsub!("PLUGIN_NAME", @pname)
          contents.gsub!(/class\s+#{@pname}/, @pname.camelize)
          contents.gsub!(/module\s+#{@pname}/, @pname.camelize)
          contents
        }
      end

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

      m.readme "README"
      m.install_with_expand("README")
      m.install_with_expand("MIT-LICENSE")
      m.install_with_expand("Rakefile")
      m.install_with_expand("init.rb")
      m.install_with_expand("install.rb")
      m.install_with_expand("uninstall.rb")
      m.install_with_expand("config/routes.rb")
      m.install_with_expand("gitignore", ".gitignore")
      m.install_with_expand("lib/PLUGIN.rb", "lib/#{args[0]}.rb")
      m.install_with_expand("spec/factories.rb")
      m.install_with_expand("tasks/PLUGIN_tasks.rake", "tasks/#{args[0]}_tasks.rake")
      m.install_with_expand("tasks/cucumber.rake")
      m.install_with_expand("tasks/rspec.rake")
    end
  end

  def after_generate
    require destination_path('install.rb')
  end
end
