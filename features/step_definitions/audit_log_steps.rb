When /^I visit the url for the last audit action by "([^"]*)"$/ do |email|
  last_version_id = Version.find(:all, :conditions =>{:whodunnit => User.find_by_email(email).id.to_s}, :order=>'id DESC', :limit=>1).first.id
  When %Q{I visit the url "/audits/#{last_version_id}.html"}
end