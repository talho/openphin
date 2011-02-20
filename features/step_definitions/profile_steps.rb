Given '$email has a $public profile' do |email, pub|
  user = User.find_by_email!(email)
  user.public = (pub == 'public')
  user.save!
end

When /^I view the profile page for "([^\"]*)"/ do |email|
  user = User.find_by_email!(email)
  visit user_profile_path(user)
end

When /^I edit the profile for "([^\"]*)"/ do |email|
  user = User.find_by_email!(email)
  visit edit_user_profile_path(user)
end

When /^I access the profile json for "([^\"]*)"/ do |email|
  user = User.find_by_email!(email)
  visit edit_user_profile_path(user) + ".json"
end

Then 'I can see the profile' do
  page.should have_css('.user_profile')
end

Then /^I can not see the profile$/ do
  page.should_not have_css('.user_profile')
end

Then /^I should see the profile edit form$/ do
  within(".profile_edit") do
	  page.should have_css(".email_address")
	  page.should have_css(".bio")
  end
end

Then /^I should see the profile page$/ do
	page.should have_css(".user_profile")
end

Then /^I should see the profile page for "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  URI.parse(current_url).path.should == user_profile_path(user)
end

Then /^I should not see any errors$/ do
  page.should_not have_css(".flash .error")
end

Then /^I can see the following roles:$/ do |table|
  table.rows_hash.each do |role, jurisdiction|
    waiter do
      page.find(".roles", :text => "#{role} in #{jurisdiction}")
    end.should_not be_nil
  end
end

Then /^I should not see the following roles:$/ do |table|
  table.rows_hash.each do |role, jurisdiction|
    within(".roles *") do
      page.should have_content("#{role} in #{jurisdiction}")
    end
  end
end
