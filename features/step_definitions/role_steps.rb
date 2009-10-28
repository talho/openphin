Given /^there is an system only (.*) role$/ do |role_name|
  role = Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  role.update_attributes!(:user_role => false)
end

Given '$role is a non public role' do |role_name|
  role = Role.find_by_name(role_name)
  role.update_attributes(:approval_required => true)
end

Given /^the role "([^\"]*)" is an alerter$/ do |role|
  Role.find_by_name(role).update_attributes! :alerter => true
end

Then 'I should have the "$role" role in "$jurisdiction"' do |role_name, jurisdiction_name|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  current_user.role_memberships.find_by_role_id_and_jurisdiction_id!(role, jurisdiction)
end

Then '"$email" should have the "$role" role in "$jurisdiction"' do |email, role, jurisdiction|
  user = User.find_by_email!(email)
  role = Role.find_by_name!(role)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction)
  user.role_memberships.find_by_role_id_and_jurisdiction_id(role, jurisdiction).should_not be_nil
end

Then '"$email" should not have the "$role" role in "$jurisdiction"' do |email, role, jurisdiction|
  user = User.find_by_email!(email)
  role = Role.find_by_name!(role)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction)
  user.role_memberships.find_by_role_id_and_jurisdiction_id(role, jurisdiction).should be_nil
end  

Then /^I should explicitly not see the "(.*)" role as an option$/ do |name|
  role = Role.find_by_name!(name)
  response.should_not have_selector("input[name*=role_id]", :value => role.id.to_s)
end

Then '"$email" should not have the "$role" role' do |email, role|
  user = User.find_by_email!(email)
  user.has_public_role?.should be_false
end
Then /^I should see "(.*)" in the role select$/ do |role|
  response.should have_selector("select.role_select option", :content => role)
end