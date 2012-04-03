Given /^I view the ext profile page for "([^"]*)"$/ do |email|
  sleep 1
  u = User.find_by_email(email)
  tab_config = "{title:'View Profile:#{u.first_name} #{u.last_name}', user_id:#{u.id}, id: 'user_profile_for_#{u.id}', initializer: 'Talho.ShowProfile'}"
  force_open_tab("", "",tab_config)
end

Given /^I visit the Edit Profile page for "([^"]*)"$/ do |email|
  u = User.find_by_email(email)
  tab_config = "{title:'Edit Profile:#{u.first_name} #{u.last_name}', url:'#{ user_profile_path(u) }', id: 'edit_profile_for_#{u.id}', initializer: 'Talho.EditProfile'}"
  force_open_tab("hello", "","#{tab_config}")
end

When /^I edit the user profile for "([^"]*)"$/ do |user_name|
  step %Q{I navigate to "Admin > Manage Users > Edit Users"}
  #step %Q{I fill in "Name:" with "#{user_name}"}
  #step %Q{I press "Search"}
#  step %Q{I suspend cucumber}
#  debugger
  step %Q{I should see "#{user_name}" within ".x-grid3-row"}
  step %Q{I click x-grid3-cell "#{user_name}"}
  step %Q{I should see "Edit User"}
  step %Q{I press "Edit User"}
  step %Q{I wait for the "Loading..." mask to go away}
end

When /^I request the org "([^"]*)" in the OrgsControl$/ do |org|
  step %Q{I press "Request Organization"}
  step %Q{I select "#{org}" from ext combo "rq[org]"}
  step %Q{I press "Add"}
end

When /^I remove the org "([^"]*)" in the OrgsControl$/ do |org|
  step %Q{I click profile-destroy "#{org}"}
end

When /^I remove the org "([^"]*)" from EditProfile$/ do |org|
  step %Q{I remove the org "#{org}" in the OrgsControl}
  step %Q{I press "Apply Changes"}
  step %Q{I should see "Profile information saved"}
  step %Q{delayed jobs are processed}
end

When /^I request the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  step %Q{I press "Request Role"}
  step %Q{I fill in "rq[role]" with "#{role}"}
  step %{I wait for the "loading" mask to go away}
  step %Q{I select "#{role}" from ext combo "rq[role]"}
  step %{I wait for the "loading" mask to go away}
  step %Q{I fill in "rq[jurisdiction]" with "#{jurisdiction}"}
  step %{I wait for the "loading" mask to go away}
  step %Q{I select "#{jurisdiction}" from ext combo "rq[jurisdiction]"}
  step %Q{I press "Add"}
end

When /^I add the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #step %Q{I press "edit" within "#edit_role"}
  step %Q{I request the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  step %Q{I press "Apply Changes"}
  step %Q{I should see "Profile information saved"}
  step %Q{delayed jobs are processed}
end

When /^I remove the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  #step %Q{I click role-item "#{jurisdiction} #{role}"}
  #step %Q{I press "Remove role"}
  step %Q{I click profile-destroy "#{role}"}
end

When /^I remove the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #step %Q{I press "edit" within "#edit_role"}
  step %Q{I remove the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  step %Q{I press "Apply Changes"}
  step %Q{I should see "Profile information saved"}
  step %Q{delayed jobs are processed}
end

When /^I fill in the add user form with:/ do |table|
  step %Q{I navigate to "Admin > Manage Users > Add a User"}
  table.rows_hash.each { |label,value|
    case label.strip
    when /Language/, /Jurisdiction/
      step %Q{I open ext combo "#{label.strip}"}
      step %Q{I click x-combo-list-item "#{value.strip}"}
    else
      step %Q{I fill in "#{label}" with "#{value.strip}"}
    end
  }
end
