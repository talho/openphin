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

Given /^there is an system administrator role$/ do
  Role.superadmin
end

When /^I go the roles show attributes page with "([^\"]*)"$/ do |request|
  raise "Request is malformed (uuid property missing)" unless request =~ /\{"uuid\"\:\"([^\"]*)\"/x
  raise "Request is malformed (class_method property missing)" unless request =~ /\{"class_method\"\:\"([^\"]*)\"/x
  raise "Request is malformed (key property missing)" unless request =~ /\{"key\"\:\"([^\"]*)\"/x
  raise "Request is malformed (value property missing)" unless request =~ /\{"value\"\:\"([^\"]*)\"/x
  raise "Request is malformed (updated_at_secs property missing)" unless request =~ /\{"updated_at_secs\"\:\"([^\"]*)\"/x
  visit path_to("the roles show attribute page", request) # merge in :format
end


Then /^I should see user role attributes with the following\:$/ do |table|
debugger
  json = ActiveSupport::JSON.decode(response.body)
  values = table.is_a?(Array) ? table : table.raw
  values.each do |row|
    property, value = row
    case property
    when /^updated_at_secs$/
      json['updated_at_secs']['text'].should_not be_nil
    else
      json[property].should == Role.find_by_id(property.to_i)
    end
  end
end


 