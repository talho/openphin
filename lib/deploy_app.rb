def if_plugin_present(plugin_name)
  yield if fetch(:phin_plugins, []).include?(plugin_name.to_sym)
end

def file_exists?(file_name)
  with_config_variable :default_shell, 'sh -l' do
    exist = capture %Q{[ -f #{file_name} ] && echo "true" || echo "false" }
    !(exist =~ /true/).nil?
  end
end

def dir_exists?(dir_name)
  with_config_variable :default_shell, 'sh -l' do
    exist = capture %Q{[ -d #{dir_name} ] && echo "true" || echo "false" }
    !(exist =~ /true/).nil?
  end
end

def with_config_variable(var_name, var_value)
  begin
    save = fetch var_name if exists? var_name
    set var_name, var_value
    yield if block_given?
  ensure
    if save
      set var_name, save
    else
      unset var_name
    end
  end
end

namespace :app do
  desc "migrate the PHIN plugins"
  task :phin_plugins_migrate, :roles => [:app, :web, :jobs] do
    fetch(:phin_plugins, []).each { |pp|
      name = pp.to_s
      run "cd #{release_path} && RAILS_ENV=production #{rake} db:migrate:#{name} db:seed:#{name}"
    }
  end

  desc "copy the yml files that we're going to be using to configure this server"
  task :install_yml, :roles => [:app, :web, :jobs] do
    upload "config/initializers/smtp.rb.example", "#{shared_path}/smtp.rb" unless file_exists?("#{shared_path}/smtp.rb")
    
    upload "config/backgroundrb.yml.example", "#{shared_path}/backgroundrb.yml" unless file_exists?("#{shared_path}/backgroundrb.yml")
    upload "config/database.yml.example", "#{shared_path}/database.yml" unless file_exists?("#{shared_path}/database.yml")
    upload "config/domain.yml", "#{shared_path}/domain.yml" unless file_exists?("#{shared_path}/domain.yml")
    upload "config/email.yml.example", "#{shared_path}/email.yml" unless file_exists?("#{shared_path}/email.yml")
    upload "config/mongo_database.yml.example", "#{shared_path}/mongo_database.yml" unless file_exists?("#{shared_path}/mongo_database.yml")
    upload "config/phone.yml.example", "#{shared_path}/phone.yml" unless file_exists?("#{shared_path}/phone.yml")
    upload "config/sphinx.yml.example", "#{shared_path}/sphinx.yml" unless file_exists?("#{shared_path}/sphinx.yml")
    upload "config/swn.yml.example", "#{shared_path}/swn.yml" unless file_exists?("#{shared_path}/swn.yml")
    
    run "mkdir #{shared_path}/tutorials" unless dir_exists?("#{shared_path}/tutorials")
    run "mkdir #{shared_path}/attachments" unless dir_exists?("#{shared_path}/attachments")
    run "mkdir #{shared_path}/sphinx" unless dir_exists?("#{shared_path}/sphinx")
    run "mkdir #{shared_path}/phin_plugins" unless dir_exists?("#{shared_path}/phin_plugins")
    
    if_plugin_present(:han){
      upload "config/initializers/cascade.yml.example", "#{shared_path}/cascade.yml" unless file_exists?("#{shared_path}/cascade.yml")
    }
    if_plugin_present(:rollcall) {
      upload "config/interface_fields.yml", "#{shared_path}/interface_fields.yml" unless file_exists?("#{shared_path}/interface_fields.yml")
    }
        
    run "mkdir -p #{shared_path}/vendor/cache" unless dir_exists?("#{shared_path}/vendor/cache")
  end
  
  set :symlinks_executed, false
  
  desc "we need a database. this helps with that."
  task :symlinks, :roles => [:app, :web, :jobs] do 
    next if fetch :symlinks_executed
    run "ln -fs #{shared_path}/smtp.rb #{release_path}/config/initializers/smtp.rb"
    
    run "ln -fs #{shared_path}/backgroundrb.yml #{release_path}/config/backgroundrb.yml"
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/domain.yml #{release_path}/config/domain.yml"
    run "ln -fs #{shared_path}/email.yml #{release_path}/config/email.yml"
    run "ln -fs #{shared_path}/mongo_database.yml #{release_path}/config/mongo_database.yml"
    run "ln -fs #{shared_path}/phone.yml #{release_path}/config/phone.yml"
    run "ln -fs #{shared_path}/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -fs #{shared_path}/swn.yml #{release_path}/config/swn.yml"
    
    run "ln -fs #{shared_path}/tutorials #{release_path}/public/tutorials"
    run "ln -fs #{shared_path}/attachments #{release_path}/attachments"
    
    if_plugin_present(:han){
      run "ln -fs #{shared_path}/cascade.yml #{release_path}/config/cascade.yml"
      run "ln -fs #{shared_path}/certificates/cdc.pem #{release_path}/config/cdc.pem"
    }
    if_plugin_present(:rollcall) {
      run "ln -fs #{shared_path}/interface_fields.yml #{release_path}/config/interface_fields.yml"
    }

    run "mkdir -p #{release_path}/vendor/cache"
    run "ln -fs #{shared_path}/vendor/cache #{release_path}/vendor/cache"
    run "mkdir #{release_path}/tmp/cache"
    
    set :symlinks_executed, true
  end
  
  desc "install required applications"
  task :install_requirements, :roles => [:app, :web, :jobs] do
    with_config_variable :default_shell, 'sh -l' do
      # Ruby requirements
      run "sudo apt-get install -qy build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion"
      
      # Openphin requirements
      run "sudo apt-get install -qy clamav libclamav6 libclamav-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev libpq-dev nodejs sphinxsearch imagemagick"
      
      unless file_exists?("/usr/local/bin/wkhtmltopdf")
        run "sudo wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2"
        run "sudo tar xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2"
        run "sudo mv wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf"
        run "sudo chmod +x /usr/local/bin/wkhtmltopdf"
      end
    end
  end  
end
