When /^I fill out the assign roles form with:$/ do |table|
  fill_in_assign_role_form table
  click_button "Assign Role"
end

When /^I maliciously post the assign role form with:$/ do |table|
  maliciously_post_assign_role_form(table)
end

When /^I maliciously post a deny for a role assignment for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email(user_email)
  role_assignment = user.role_memberships.first
  delete_via_redirect role_assignment_path(role_assignment)
end
