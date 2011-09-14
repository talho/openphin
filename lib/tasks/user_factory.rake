desc 'Create many factory users, defaults to 1, USERS=nnnnnn for more, limit 20_000'
namespace :db do
  task :create_users => :environment do
    require File.join(Rails.root,'spec','factories.rb')
    limit = ENV["USERS"].to_i || 1
    limit = 20_000 if limit > 20_000
    existing = User.count
    puts "Creating users"
    start_time = Time.now
      (existing+1..existing+limit).each do |e|
        Factory.create(:user,:email=>"user#{e}@example.com",:first_name=>"User#{e}")
      end
    puts "Created #{User.count-existing} user(s) in #{Time.now-start_time} milliseconds."
  end
end

