# For bundler!
#source "http://gemcutter.org"
source "http://rubygems.org"
#source "http://gems.github.com" 

group :default do
  gem "rails", "~> 3.1.0"
  gem "clearance", "~> 0.16.0"
  gem "prawn", "0.8.4"
  gem "paperclip", "2.7.0"
  gem "rack-raw-upload"
  gem "httparty", "0.8.1"
  gem "crack", "0.1.8"
  gem "validatable", "1.6.7"
  gem "will_paginate", "~> 3"
  gem "RedCloth"
  gem "feedzirra", "0.0.23"
  gem "curb", "0.7.15"
  gem "happymapper", :git => 'git://github.com/talho/happymapper.git' #"0.3.2"
  gem "libxml-ruby", "~> 2.3"
  gem "pg", ">= 0.11"
  gem "acts-as-taggable-on", "~> 2.2.0"
  gem "paper_trail", ">= 2"
  gem "wicked_pdf", "0.7.0"
  gem "mongo", "1.3.1"
    gem "bson", "1.3.1"
    gem "bson_ext", "1.3.1"
  gem "base32-crockford", "0.1.0"
  gem 'savon', '0.9.7'
  gem 'httpi', :git => 'git://github.com/talho/httpi.git'
  gem "httpclient", :git => 'git://github.com/talho/httpclient.git'
  gem 'thinking-sphinx', '~> 2.0.11', :require => 'thinking_sphinx/deltas/delayed_delta'
    gem 'ts-delayed-delta'
  gem "delayed_job", "~> 3.0.1"
    gem 'delayed_job_active_record', "~> 0.3"
  gem 'option_attrs', :git => 'git://github.com/talho/option_attrs.git'
  gem 'pin_cushion', :git => 'git://github.com/talho/pin_cushion.git'
  gem 'backgroundrb-rails3', :require => 'backgroundrb'
    gem "packet", "0.1.15"
    gem "chronic", "0.2.3"
  gem "no_peeping_toms", "~> 1.1.0"  # 2.x versions require rails3
  gem "caching_presenter", :git => 'git://github.com/talho/caching_presenter.git'
  gem 'jbuilder', :git => 'git://github.com/rails/jbuilder.git'
  gem 'awesome_nested_set'
  gem 'sinatra'
  gem "dynamic_form"
  gem "rails_sql_views", :git => 'git://github.com/talho/rails_sql_views.git'
  
  gem "yajl-ruby", :require => ['yajl', 'yajl/json_gem']
end

group :development do
  # gem "jslint_on_rails"
  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'rails-dev-tweaks', '~> 0.6.1'
  gem "capistrano-unicorn"
end

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
#  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :test do
  gem "rspec"#, "2.1.0"
  gem "rspec-rails"#, "1.3.4"
end
 
group :cucumber do
  gem "factory_girl"#, "1.3.3", :require => "factory_girl"
   
  gem "cucumber", "1.1.9"
  gem "capybara" #, "0.4.1.2"
  gem "gherkin", "2.9.3"
  gem "cucumber-rails"#, "1.3.0"
  gem "database_cleaner"#, "0.5.0"
  gem "spork"#, "0.8.4"
 
  gem "childprocess"
  gem "selenium-webdriver"#, '2.8.0'
  gem "chromedriver-helper"
  gem "headless"
end
 
group :production do
  gem "unicorn"
  gem "clamav", "0.4.1"
end
 
group :tools do
  gem "launchy"
  gem "capistrano"
  gem "rubyforge"
  gem "hoe"
  gem "git"
  gem "git_remote_branch"
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  gem 'ruby-debug19'
  gem "simplecov"
end
