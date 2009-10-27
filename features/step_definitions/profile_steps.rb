Given '$email has a $public profile' do |email, pub|
  user = User.find_by_email!(email)
  user.public = (pub == 'public')
  user.save!
end

When /I view the profile page for "([^\"]*)"/ do |email|
  user = User.find_by_email!(email)
  visit user_profile_path(user)
end

When /I edit the profile for "([^\"]*)"/ do |email|
  user = User.find_by_email!(email)
  visit edit_user_profile_path(user)
end

Then 'I can see the profile' do
  response.should have_selector('.user_profile')
end

Then /^I can not see the profile$/ do
  response.should_not have_selector('.user_profile')
end

Then /^I should see the profile edit form$/ do
  response.should have_selector(".profile_edit") do |form|
	  form.should have_selector(".email_address")
	  form.should have_selector(".bio")
  end
end

Then /^I should see the profile page$/ do
	response.should have_selector(".user_profile")
end

Then /^I should see the profile page for "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  URI.parse(current_url).path.should == user_profile_path(user)
end

Then /^I should not see any errors$/ do
  response.template.assigns['user'].errors.should be_empty
end

Then /^I can see the following roles:$/ do |table|
  table.rows_hash.each do |role, jurisdiction|
    response.should have_selector(".roles *", :content => "#{role} in #{jurisdiction}")
  end
end

Then /^I should not see the following roles:$/ do |table|
  table.rows_hash.each do |role, jurisdiction|
    response.should_not have_selector(".roles *", :content => "#{role} in #{jurisdiction}")
  end
end