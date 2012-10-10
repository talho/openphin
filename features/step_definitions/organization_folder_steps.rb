Given /^I am an organization admin for "([^\"]*)"$/ do |orgname|
  assert Organization.find_by_name(orgname).contact.id == current_user.id
end

Then /^I am a folder admin for "([^\"]*)"$/ do |orgname|
  assert Folder.find_by_name(orgname).owner?(current_user)
end

Given /^I have (a not shared )?folder "([^\"]*)" under organization "([^\"]*)"(?: with audience "([^\"]*)")?$/ do |notshared, foldername, orgname, audience|
  org = Folder.find_by_name(orgname)
  folder = Folder.create :name => foldername, :organization_id => org.organization_id, :parent_id => org.id
  if notshared
    folder.audience_id = nil
    folder.save!
  end
  if audience
    folder.audience = Audience.new :user_ids => [User.find_by_email(audience).id]
    folder.save!
  end
  step %Q{I press "Refresh"}
end