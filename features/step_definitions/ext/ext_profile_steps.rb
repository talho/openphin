Given /^I view the ext profile page for "([^"]*)"$/ do |email|
  u = User.find_by_email(email)
  tab_config = "{title:'Edit Profile:#{u.first_name} #{u.last_name}', user_id:'#{u.id}', id: 'user_profile_for_#{u.id}', initializer: 'Talho.ShowProfile'}"
  force_open_tab("hello", "","#{tab_config}")
end

When /^I edit the user profile for "([^"]*)"$/ do |user_name|
  When %Q{I navigate to "Admin > Manage Users > Edit Users"}
  #When %Q{I fill in "Name:" with "#{user_name}"}
  #When %Q{I press "Search"}
  When %Q{I should see "#{user_name}" within ".x-grid3-row"}
  When %Q{I click x-grid3-cell "#{user_name}"}
  Then %Q{I should see "Edit User"}
  When %Q{I press "Edit User"}
end

When /^I request the org "([^"]*)" in the OrgsControl$/ do |org|
  When %Q{I press "Request Organization"}
  When %Q{I select "#{org}" from ext combo "rq[org]"}
  When %Q{I press "Add"}
end

When /^I request the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  When %Q{I press "Request Role"}
  When %Q{I select "#{role}" from ext combo "rq[role]"}
  When %Q{I select "#{jurisdiction}" from ext combo "rq[jurisdiction]"}
  When %Q{I press "Add"}
end

When /^I add the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #When %Q{I press "edit" within "#edit_role"}
  When %Q{I request the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  When %Q{I press "Apply Changes"}
  Then %Q{I should see "Profile information saved"}
  When %Q{delayed jobs are processed}
end

When /^I remove the role "([^"]*)" for "([^"]*)" in the RolesControl$/ do |role,jurisdiction|
  #When %Q{I click role-item "#{jurisdiction} #{role}"}
  #When %Q{I press "Remove role"}
  When %Q{I click destroy "#{role}"}
end

When /^I remove the role "([^"]*)" for "([^"]*)" from EditProfile$/ do |role,jurisdiction|
  #When %Q{I press "edit" within "#edit_role"}
  When %Q{I remove the role "#{role}" for "#{jurisdiction}" in the RolesControl}
  When %Q{I press "Apply Changes"}
  Then %Q{I should see "Profile information saved"}
  When %Q{delayed jobs are processed}
end

When /^I fill in the add user form with:/ do |table|
  When %Q{I navigate to "Admin > Manage Users > Add a User"}
  table.rows_hash.each { |label,value|
    case label
    when /Language/, /Jurisdiction/
      When %Q{I open ext combo "#{label}"}
      When %Q{I click x-combo-list-item "#{value}"}
    else
      When %Q{I fill in "#{label}" with "#{value}"}
    end
  }
end
