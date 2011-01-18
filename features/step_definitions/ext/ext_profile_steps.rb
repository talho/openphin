Given /^I view the ext profile page for "([^"]*)"$/ do |email|
  u = User.find_by_email(email)
  tab_config = "{title:'Edit Profile:#{u.first_name} #{u.last_name}', user_id:'#{u.id}', id: 'user_profile_for_#{u.id}', initializer: 'Talho.ShowProfile'}"
  When %Q{I force open the tab "hello" for "" with config "#{tab_config}"}
end

When /^I edit the user profile for "([^"]*)"$/ do |user_name|
  When %Q{I navigate to "Admin > Manage Users > Edit Users"}
  When %Q{I click x-grid3-row "#{user_name}"}
  When %Q{I press "Edit User"}
end

When /^I add the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  When %Q{I press "Add role"}
  When %Q{I select "#{role}" from ext combo "rq[role]"}
  When %Q{I select "#{jurisdiction}" from ext combo "Jurisdiction"}
  When %Q{I press "Add"}
end

When /^I add the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #When %Q{I press "edit" within "#edit_role"}
  When %Q{I add the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  When %Q{I press "Apply Changes"}
  When %Q{delayed jobs are processed}
end

When /^I remove the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  When %Q{I click role-item "#{jurisdiction} #{role}"}
  When %Q{I press "Remove role"}
end

When /^I remove the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #When %Q{I press "edit" within "#edit_role"}
  When %Q{I remove the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  When %Q{I press "Apply Changes"}
  When %Q{delayed jobs are processed}
end
