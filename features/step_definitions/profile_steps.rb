Then /^I should see the profile edit form$/ do
  response.should have_selector(".profile_edit") do |form|
	  form.should have_selector(".email_address")
	  form.should have_selector(".bio")
  end
end

Then /^I should see the profile page$/ do
	response.should have_selector(".user_profile")
end

Then /^I should not see any errors$/ do
  response.template.assigns['user_profile'].errors.should be_empty
  response.template.assigns['user_profile'].user.errors.should be_empty
end