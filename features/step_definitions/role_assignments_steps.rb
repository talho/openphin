When /^I fill out the assign roles form with:$/ do |table|
  fill_in_assign_role_form table
  click_button "Assign Role"
end

When /^I maliciously post the assign role form with:$/ do |table|
  maliciously_post_assign_role_form(table)
end