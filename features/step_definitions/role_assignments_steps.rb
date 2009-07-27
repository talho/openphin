When /^I fill out the assign roles form with:$/ do |table|
  fill_in_assign_role_form table
  click_button "Assign Role"
end