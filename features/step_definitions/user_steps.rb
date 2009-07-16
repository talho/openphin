Given "a user named $name" do |name|
  first_name, last_name = name.split
  User.find_by_first_name_and_last_name(first_name, last_name) ||
    Factory(:user, :first_name => first_name, :last_name => last_name)
end

Given 'the user "$name" with the email "$email" has the role "$role" in "$jurisdiction"' do |name, email, role, jurisdiction|
  user = Given "a user named #{name}"
  user.update_attributes :email => email
  user.role_memberships.create!(:role => Given("a role named #{role}"), :jurisdiction => Given("a jurisdiction named #{jurisdiction}"))
end

Given 'the following users exist:' do |table|
  table.raw.each do |row|
    Given %Q{the user "#{row[0]}" with the email "#{row[1]}" has the role "#{row[2]}" in "#{row[3]}"}
  end
end

Given 'I am logged in as "$email"' do |email|
  user = User.find_by_email!(email)
  login_as user
end

Given 'I am allowed to send alerts' do
  current_user.role_memberships(:role => Factory(:role, :alerter => true), :jurisdiction => Factory(:jurisdiction))
end

Given 'I have confirmed my account for "$email"' do |email|
  User.find_by_email!(email).confirm_email!
end

Given /^(.*) has the following administrators:$/ do |jurisdiction_name, table|
  role = Role.admin || Factory(:role, :name => Role::ADMIN)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  table.raw.each do |row|
    first_name, last_name = row.first.split(/\s+/)
    user = Factory(:user, :first_name => first_name, :last_name => last_name, :email => row.last)
    membership = user.role_memberships.create :role => role, :jurisdiction => jurisdiction, :user => user
    user.reload.role_memberships.should include(membership)
  end
end

Given /^"([^\"]*)" has been approved for the role "([^\"]*)"$/ do |user_email, role_name|
  user=User.find_by_email!(user_email)
  role=Role.find_by_name!(role_name)
  role_request=user.role_requests.find_by_role_id!(role.id)
  role_request.approve!(role_request.jurisdiction.admins.first)
end
def fill_in_signup_form(table = nil)
  fields={"Email"=> "john@example.com",
      "Password"=> "password",
      "Password confirmation"=> "password",
      "First name"=> "John",
      "Last name"=> "Smith",
      "Preferred name"=> "Jonathan Smith",
      "Are you with any of these organizations"=> "Red Cross",
      "What County"=> "Dallas County",
      "What is your role within the health department"=> "Health Alert and Communications Coordinator",
      "Preferred language"=> "English"
  }
  if table.is_a?(Hash)
    fields.merge!(table)
  elsif !table.nil?
    fields.merge!(table.rows_hash)
  end
  fields.each do |field, value|
    value = "" if value == "<blank>"
    case field
    when 'Email', 'Password', 'Password confirmation', 'First name', 'Last name', 'Preferred name'
      fill_in field, :with => value
    when 'What County', 'Preferred language', 
      'What is your role within the health department', 
      'Are you with any of these organizations'
        select value, :from => field
    else
      raise "Unknown field: #{field}: Please update this step if you intended to use this field."
    end
  end
      
end
When /^I sign up for an account as "([^\"]*)"$/ do |email|
  visit new_user_path
  fill_in_signup_form("Email" => email)
  click_button "Save"
end

When 'I signup for an account with the following info:' do |table|
  visit new_user_path
  fill_in_signup_form(table)
  click_button 'Save'
end

When /^I log in as "([^\"]*)"$/ do |user_email|
  login_as User.find_by_email!(user_email)
end

When /^"([^\"]*)" clicks the confirmation link in the email$/ do |user_email|
  email=ActionMailer::Base.deliveries.last
  user=User.find_by_email!(user_email)
  link=user_confirmation_path(user, user.token)
  email.body.should contain(link)
  visit link
end

Then '"$email" should have the "$role" role for "$jurisdiction"' do |email, role, jurisdiction|
  p=User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = p.role_memberships.find_by_role_id_and_jurisdiction_id(r.id, j.id)
  m.should_not be_nil
end

Then '"$email" should have the "$role" role request for "$jurisdiction"' do |email, role, jurisdiction|
  p=User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = RoleRequest.find_by_role_id_and_jurisdiction_id_and_requester_id(r.id, j.id, p.id)
  m.should_not be_nil
end
