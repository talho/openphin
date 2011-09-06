def if_plugin_present(plugin_name)
  plugins = YAML.load_file("config/phin_plugins.yml")
  yield if plugins.find {|e| e["url"] =~ /\b#{plugin_name}\b/}
end

namespace :app do
  desc "deploy the PHIN plugins: han, etc."
  task :phin_plugins, :roles => [:app, :web, :jobs] do
    YAML.load_file("config/phin_plugins.yml").each { |pp|
      cmds = [ "cd #{release_path}" ]
      name = File.basename(pp["url"]).sub(/\.git$/, "")
      branch = pp["branch"] || "master"
      cmds << "git clone #{pp["url"]} --branch #{branch} vendor/plugins/#{name}"
      cmds << "cd vendor/plugins/#{name}"
      cmds << "git checkout #{pp["commit"]}" if pp.has_key?("commit")
      cmds << "git submodule update -i"
      run cmds.join(" && ")
    }
  end

  desc "install the PHIN plugins: han, etc."
  task :phin_plugins_install, :roles => [:app, :web, :jobs] do
    YAML.load_file("config/phin_plugins.yml").each { |pp|
      name = File.basename(pp["url"]).sub(/\.git$/, "")
      run "cd #{release_path} && RAILS_ENV=production ./script/runner vendor/plugins/#{name}/install.rb"
      run "cd #{release_path} && RAILS_ENV=production #{rake} db:migrate:#{name} db:seed:#{name}"
    }
  end

  desc "we need a database. this helps with that."
  task :symlinks, :roles => [:app, :web, :jobs] do 
    run "ln -fs #{shared_path}/#{rails_env}.sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
    run "ln -fs #{shared_path}/smtp.rb #{release_path}/config/initializers/smtp.rb"
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/sphinx #{release_path}/db/sphinx"
    run "ln -fs #{shared_path}/backgroundrb.yml #{release_path}/config/backgroundrb.yml"
    run "ln -fs #{shared_path}/swn.yml #{release_path}/config/swn.yml"
    run "ln -fs #{shared_path}/email.yml #{release_path}/config/email.yml"
    run "ln -fs #{shared_path}/phone.yml #{release_path}/config/phone.yml"
    run "ln -fs #{shared_path}/system.yml #{release_path}/config/system.yml"
    run "ln -fs #{shared_path}/phin_ms_queues #{release_path}/tmp/phin_ms_queues"
    run "ln -fs #{shared_path}/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -fs #{shared_path}/hydra.yml #{release_path}/config/hydra.yml"
    run "ln -fs #{shared_path}/tutorials #{release_path}/public/tutorials"
    run "ln -fs #{shared_path}/attachments #{release_path}/attachments"
    run "ln -fs #{shared_path}/document.yml #{release_path}/config/document.yml"
    run "ln -fs #{shared_path}/dashboard.yml #{release_path}/config/dashboard.yml"
    # For the PHIN plugins
    if_plugin_present(:rollcall) {
      run "ln -fs #{shared_path}/phin_plugins/rrdtool.yml #{release_path}/vendor/plugins/rollcall/config/rrdtool.yml"
    }

    run "ln -fs #{shared_path}/vendor/cache #{release_path}/vendor/cache"
    if rails_env == 'test'|| rails_env == 'development' || rails_env == "cucumber"
      run "ln -fs #{shared_path}/backgroundrb.yml#{release_path}/config/backgroundrb.yml"
      run "ln -fs #{shared_path}/system.yml#{release_path}/config/system.yml"
    end
    run "mkdir #{release_path}/tmp/cache"
  end

  desc "run bundle install for gem dependencies"
  task :bundle_install, :roles => [:app, :web, :jobs] do
    if rails_env == "test"
      run "cd #{release_path}; bundle install --without=tools"
    else
      run "cd #{release_path}; bundle install --without=test --without=cucumber --without=tools"
    end
  end
end
