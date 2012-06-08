# OpenPHIN

OpenPHIN is a portal and framework for public health related projects.

## Prerequisites

Install ruby 1.9.3, bundler, Postgresql, and if you want reporting, MongoDB. Works with both Postgresql 8.4 and 9.1.

For development, you need the curl development libraries, the postgres dev libraries, some JS engine (node is easy), and sphinx. For
production, you'll also need clamav. This should be sufficient to run the application (for Ubuntu):

    sudo apt-get install -qy clamav libclamav6 libclamav-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev libpq-dev nodejs sphinxsearch

## Installation

1. ```git clone git://github.com/talho/openphin.git```
1. ```bundle install```
1. Copy all the config/\*.yml.example files as config/\*.yml files. Modify your database .yml file appropriately
1. ```rake db:create && rake db:migrate```
1. ```rails s```

## Testing

Testing takes advantage of Xvfb to run headlessly on your server. This is a good thing because the testing library is rather large
and takes some significant time to complete. You may need to install xvfb.

#### Preparing the test environment

    sudo apt-get install xvfb
    RAILS_ENV=cucumber rake db:create && rake db:migrate
  
#### Running tests

    cucumber

## Notes

Some things that might help during install/upgrade:

#### Rails 3 Upgrade
  - You should be able to upgrade directly from the old version of OpenPHIN to the new. The most recent OpenPHIN master uses Ruby 1.9.3
  - Fix dashboards before deploying. run in console:

``` ruby
Portlet.all.each {|p| p.update_attributes config: ActiveSupport::JSON.decode(p.config).to_json }
```

#### PHIN Extensions/Plugins

Additional functionality can be added via extension gems. These can now be run entirely as gems without. There is a generator in place, but
as of this writing it is outdated.

These extensions are currently available:
  - HAN: Health Alert Network for alerting. Written to support Health and Communication Coordinators. CDC Cascade alerting certified.
  - Rollcall: Attendance and ILI surveillance and analysis.
  - VMS: Volunteer managment system. Capabilities include scenario execution and templating, volunteer check-in/check-out, and volunteer alerting

Please contact TALHO (or one of the contributors) for more information.