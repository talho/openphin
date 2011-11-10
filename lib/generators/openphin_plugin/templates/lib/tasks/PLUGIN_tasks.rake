namespace :db do
  namespace :migrate do
    description = "Migrate the database through scripts in vendor/plugins/<%= file_name %>/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    description << "Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    desc description
    task :<%= singular_name %> => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("vendor/plugins/<%= file_name %>/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  namespace :rollback do
    description = "Rollback the database through scripts in vendor/plugins/<%= file_name %>/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    desc description
    task :<%= singular_name %> => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.rollback("vendor/plugins/<%= file_name %>/db/migrate/")
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  namespace :seed do
    description = "Add <%= class_name %> seed data to the database"
    desc description
    task :<%= singular_name %> => :environment do
      Dir.glob(File.join(File.dirname(__FILE__),'..','db','fixtures','*.rb')).each do |file|
        require file
      end
    end
  end
end
