# For bundler!
source "http://gemcutter.org"
source "http://rubygems.org"
source "http://gems.github.com" 

group :default do
  gem "rails", "2.3.14"
    gem 'rdoc'
  gem "exception_notification", "~> 2.3.3.0"
  gem "sinatra", "1.0"
  gem "clearance", "0.8.8"
  gem "prawn", "0.8.4"
  gem "paperclip", "2.4.5"
  gem "rack-raw-upload"
  gem "httparty", "0.8.1"
  gem "crack", "0.1.8"
  gem "json_pure", "1.4.6"
  gem "validatable", "1.6.7"
  gem "will_paginate", "2.3.14"
  gem "RedCloth", "4.2.8"
  gem "hoptoad_notifier", "2.4.11"
  gem "feedzirra", "0.0.23"
  gem "builder", "2.1.2"
  gem "nokogiri", "1.4.4"
  gem "curb", "0.7.15"
  gem "happymapper", :git => 'git://github.com/talho/happymapper.git' #"0.3.2"
  gem "libxml-ruby", "1.1.3"
  gem "pg", "0.10.1"
  gem "acts-as-taggable-on", "2.0.6"
  gem "paper_trail", "1.6.5"  # 2.x versions require rails3
  gem "wicked_pdf", "0.7.0"
  gem "mongo", "1.3.1"
    gem "bson", "1.3.1"
    gem "bson_ext", "1.3.1"
  gem "base32-crockford", "0.1.0"
  gem 'savon', '0.9.7'
  gem 'httpi', :git => 'git://github.com/talho/httpi.git'
  gem "httpclient", :git => 'git://github.com/talho/httpclient.git'
  gem "fake_arel", '0.9.9'
  gem 'thinking-sphinx', '1.4.9', :require => 'thinking_sphinx/deltas/delayed_delta'
    gem 'ts-delayed-delta', '1.1.1'
    gem 'riddle', '1.4.0' # last version of rails 2.3 thinking sphinx, when using a delta ts plugin gem, requires riddle 1.4
  gem 'awesome_nested_set', '1.4.4'
  gem "delayed_job", "~> 2.0.7"
  gem 'option_attrs', :git => 'git://github.com/talho/option_attrs.git'
  gem 'pin_cushion', :git => 'git://github.com/talho/pin_cushion.git'
  gem 'smurf', :git => 'git://github.com/Dishwasha/smurf.git'
  gem 'backgroundrb', :git => 'git://github.com/talho/backgroundrb.git'
    gem "packet", "0.1.15"
    gem "chronic", "0.2.3"
  gem "no_peeping_toms", "~> 1.1.0"  # 2.x versions require rails3
  gem "caching_presenter", :git => 'git://github.com/talho/caching_presenter.git'
  gem 'bullet'
  gem 'rabl'
end

group :development do
  gem "jslint_on_rails"
end

group :test do
  gem "rspec", "2.1.0"
  gem "rspec-rails"#, "1.3.4"
  gem "factory_girl"#, "1.3.3", :require => "factory_girl"
  gem "webrat"#, "0.7.1"
  gem "rack-test"#, "0.5.4"
  gem 'test-unit'
end

group :cucumber do
  gem "cucumber", "1.1.0"
    gem "json"#, "1.4.6"
    gem "diff-lcs"#, "1.1.2"
    gem "trollop"#, "1.16.2"
    gem "gherkin"#, "2.5.4"
    gem "term-ansicolor"#, "1.0.5"
  gem "cucumber-rails", "0.3.2"
  gem "database_cleaner"#, "0.5.0"
  gem "spork"#, "0.8.4"

  gem "culerity"#, "0.2.4"
  gem "mime-types"#, "1.16"
  gem "rack-test"#, "0.5.4"
  gem "childprocess"
  gem "selenium-webdriver"#, '2.8.0'
  gem "chromedriver-helper"
  gem "headless"
  gem "xpath" #, "0.1.3"
  gem "capybara" #, "0.4.1.2"
  #gem "hydra", "0.23.3"
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
  gem "ruby-debug19"
  gem "linecache19", '0.5.12'
  gem "simplecov"
end
