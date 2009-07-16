Given /^there is an system only (.*) role$/ do |role_name|
  role = Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  role.update_attributes!(:user_role => false)
end
