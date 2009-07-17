Given /^there is an system only (.*) role$/ do |role_name|
  role = Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  role.update_attributes!(:user_role => false)
end

Then 'I should have the "$role" role in "$jurisdiction"' do |role_name, jurisdiction_name|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  current_user.role_memberships.find_by_role_id_and_jurisdiction_id!(role, jurisdiction)
end