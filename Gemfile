# For bundler!
#source "http://gemcutter.org"
source "https://rubygems.org"
#source "http://gems.github.com"

group :default do
  #temp fix because the net-ssh guys introduced an issue
  gem "net-ssh"

  # These are the gems required for phin to boot
  gem "rails", "~> 3.2.0"
  gem "clearance", "~> 0.16.0"
  gem "rack-raw-upload"
  gem "pg", ">= 0.11"
  gem 'postgres_ext'
  gem "paper_trail", ">= 2"
  gem "wicked_pdf", "0.7.9"
  gem "mongo", "1.6.2"
    gem 'bson_ext', '1.6.2'

  # These are required to boot into cucumber
  gem "caching_presenter", :git => 'git://github.com/talho/caching_presenter.git'
  gem "delayed_job", "~> 3.0.1"
    gem "daemons"
  gem "paperclip", ">= 3.0"
  gem 'thinking-sphinx', '~> 2.1'
    gem 'ts-delayed-delta', :require => 'thinking_sphinx/deltas/delayed_delta'
  gem "feedzirra", "0.0.23"
  gem 'sinatra'
  gem 'pin_cushion', :git => 'git://github.com/talho/pin_cushion.git', :branch => "db_agnostic"
  gem "happymapper", :git => 'git://github.com/talho/happymapper.git' #"0.3.2"
  gem "base32-crockford", "0.1.0"

  # These cause warnings in cucumber, errors on run
  gem 'option_attrs', :git => 'git://github.com/talho/option_attrs.git'
  gem "validatable", "1.6.7"
  gem "httparty", "0.8.1"
  gem 'awesome_nested_set'

  # These gems are used post-boot
  gem "prawn", "0.8.4"
  gem "crack", "0.1.8"
  gem "will_paginate", "~> 3"
  gem "RedCloth"
  gem "libxml-ruby", "~> 2.3"
  gem "acts-as-taggable-on", "~> 2.2.0"
  gem 'savon', '0.9.7'
  gem 'httpi', :git => 'git://github.com/talho/httpi.git'
  gem "httpclient", :git => 'git://github.com/talho/httpclient.git'
    gem 'delayed_job_active_record', "~> 0.3"
  gem 'backgroundrb-rails3', :require => 'backgroundrb', :git => 'git://github.com/talho/backgroundrb-rails3.git'
    gem "packet", "0.1.15"
    gem "chronic", ">= 0.2.3"
  gem "no_peeping_toms", "~> 1.1.0"  # 2.x versions require rails3
  gem 'jbuilder', :git => 'git://github.com/rails/jbuilder.git'
  gem "dynamic_form"
  gem "rails_sql_views", :git => 'git://github.com/talho/rails_sql_views.git'
  gem "d3_rails"
  gem "yajl-ruby", :require => ['yajl', 'yajl/json_gem']
end

group :development do
  # These are the gems required for phin to boot in dev mode
  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'rails-dev-tweaks', '~> 0.6.1'

  gem "jslint_on_rails"
  gem "capistrano-unicorn", :git => 'git://github.com/talho/capistrano-unicorn.git', :require => false
end

group :assets do
  gem 'sprockets'
  gem 'sass-rails'
# #  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :test do
  gem "rspec"#, "2.1.0"
  gem "rspec-rails"#, "1.3.4"
end

group :cucumber do
  gem "factory_girl"#, "1.3.3", :require => "factory_girl"

  gem "cucumber-rails"#, "1.3.0"
  gem "capybara" , "1.1.3"
  gem "database_cleaner", "~> 0.8.0"
  gem "spork"#, "0.8.4"

  gem "childprocess"
  gem "selenium-webdriver"#, '2.8.0'
  gem "chromedriver-helper"
  gem "headless"
end

group :production do
  gem "airbrake"
  gem "unicorn"
  gem "clamav", "0.4.1"
end

group :tools do
  # gem "launchy"
  gem "capistrano"
  gem "rvm-capistrano"
  # gem "rubyforge"
  # gem "hoe"
  # #gem "git"
  # #gem "git_remote_branch"
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  gem 'ruby-debug19'
  # gem "simplecov"
end
