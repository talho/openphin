namespace :app do
  desc "deploy the PHIN plugins: han, etc."
  task :phin_plugins, :roles => [:app, :web, :jobs] do
    phin_plugins = YAML.load_file("config/phin_plugins.yml")
    phin_plugins.each { |pp|
      cmds = [ "cd #{release_path}" ]
      name = File.basename(pp["url"]).sub(/\.git$/, "")
      branch = pp["branch"] || "master"
      cmds << "git clone #{pp["url"]} --branch #{branch} vendor/plugins/#{name}"
      if pp.has_key?("commit")
        cmds << "cd vendor/plugins/#{name}"
        cmds << "git checkout #{pp["commit"]}"
      end
      run cmds.join(" && ")
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
    run "ln -fs #{shared_path}/rollcall #{release_path}/tmp/rollcall"
    run "ln -fs #{shared_path}/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -fs #{shared_path}/hydra.yml #{release_path}/config/hydra.yml"
    run "ln -fs #{shared_path}/tutorials #{release_path}/public/tutorials"
    run "ln -fs #{shared_path}/attachments #{release_path}/attachments"
    run "ln -fs #{shared_path}/document.yml #{release_path}/config/document.yml"
    # for the rollcall plugin
    run "ln -fs #{release_path}/vendor/plugins/rollcall/lib/workers #{release_path}/lib/workers/rollcall"
    run "ln -fs #{release_path}/spec/spec_helper.rb #{release_path}/vendor/plugins/rollcall/spec/spec_helper.rb"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/javascript #{release_path}/public/javascripts/rollcall"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/stylesheets #{release_path}/public/stylesheets/rollcall"

    run "cd #{release_path}/vendor/plugins/rollcall; git submodule update -i"

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
