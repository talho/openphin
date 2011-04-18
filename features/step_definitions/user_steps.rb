Given "a user named $name" do |name|
  first_name, last_name = name.split
  User.find_by_first_name_and_last_name(first_name, last_name) ||
    Factory(:user, :first_name => first_name, :last_name => last_name)
end 

Given 'a user with the email "$email"' do |email|
  User.find_by_email(email) || Factory(:user, :email => email)
end

Given 'the user "$name" with the email "$email" has the role "$role" in "$jurisdiction"' do |name, email, role, jurisdiction|
  first_name, last_name = name.split
  jur_obj = Jurisdiction.find_or_create_by_name(jurisdiction.to_s)
  unless (user = User.find_by_email(email))
    #create the user.  this results in a Public role in the requested jurisdiction, and a role request for 'role'
    user = Factory(:user, :first_name => first_name, :last_name => last_name, :email => email)#, :role_requests_attributes => [{:jurisdiction_id => jur_obj.id, :role_id => role_obj.id }] )
  end
  roles = role.split(',').map(&:strip)
  roles.each do |r|
    role_obj = Role.find_or_create_by_name(r.to_s)
    role_obj.update_attribute('approval_required', true) unless r.to_s == "Public"
    unless r == "Public"
      unless RoleMembership.already_exists?(user, role_obj, jur_obj)
        #force creation of the role membership.  this leaves the request dangling.
        Factory(:role_membership, :role => role_obj, :jurisdiction => jur_obj, :user=> user )
        if (r_request = user.role_requests.find_by_role_id_and_jurisdiction_id(role_obj.id,jur_obj.id))
          #remove the request.
          r_request.delete
        end
      end
    end
  end
end

Given /^"([^\"]*)" has the password "([^\"]*)"$/ do |email, password|
  u=User.find_by_email(email)
  u.update_password(password,password)
  u.save
end
Given /^the following users exist:$/ do |table|
  table.raw.each do |row| 
    Given %Q{the user "#{row[0]}" with the email "#{row[1]}" has the role "#{row[2]}" in "#{row[3]}"}
  end
end

Given /^(\d+) users exist like$/ do |mob_count, table|
  # table format: | role         | [role]         |
  #               | jurisdiction | [jurisdiction] |
  mobber = 0
  while mobber < mob_count.to_i do
    Given %Q{the user "mobuser #{table.rows_hash["role"]+ mobber.to_s}" with the email "#{table.rows_hash["role"] + mobber.to_s}@example.com" has the role "#{table.rows_hash["role"]}" in "#{table.rows_hash["jurisdiction"]}"}
    mobber += 1 
  end
end

Given /^([^"]*) has the following information:$/ do |email, table|
  u=User.find_by_email(email)
  table.raw.each do |row|
    u.update_attribute(row[0],row[1])
  end
end

Given /^"([^\"]*)" has the title "([^\"]*)"$/ do |email, value|
  u=User.find_by_email(email)
  u.update_attribute(:title,value)
end

Given /^"([^\"]*)" has the phone "([^\"]*)"$/ do |email, value|
  u=User.find_by_email(email)
  u.update_attribute(:phone,value.gsub(/([^0-9])/,""))
end

Given /^"([^\"]*)" has the fax "([^\"]*)"$/ do |email, value|
  u=User.find_by_email(email)
  u.update_attribute(:fax,value.gsub(/([^0-9])/,""))
end

Given /^"([^\"]*)" has the mobile phone "([^\"]*)"$/ do |email, value|
  u=User.find_by_email(email)
  u.update_attribute(:mobile_phone,value.gsub(/([^0-9])/,""))
end

Given /^"([^\"]*)" has the home phone "([^\"]*)"$/ do |email, value|
  u=User.find_by_email(email)
  u.update_attribute(:home_phone,value.gsub(/([^0-9])/,""))
end

Given /^I am logged in as "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  login_as user
end

Given /^"([^\"]*)" is allowed to send alerts$/ do |email|
  user = User.find_by_email(email)
  user.role_memberships(:role => Factory(:role, :alerter => true), :jurisdiction => Factory(:jurisdiction))
end

Given 'I am allowed to send alerts' do
  current_user.role_memberships(:role => Factory(:role, :alerter => true), :jurisdiction => Factory(:jurisdiction))
end

Given 'I have confirmed my account for "$email"' do |email|
  user = User.find_by_email!(email)
  visit user_confirmation_path(user.id, user.token)
end

Given "the following administrators exist:" do |table|
  admin_role = Role.admin
  table.raw.each do |row|
    admin = Factory(:user, :email => row[0])
    jurisdiction = Jurisdiction.find_by_name(row[1]) || Factory(:jurisdiction, :name => row[1])
    admin.role_memberships.each do |rm|
      rm.destroy
    end
    RoleMembership.create!(:user => admin, :jurisdiction => jurisdiction, :role => admin_role)
  end
end

Given "the following organization administrators exist:" do |table|
  admin_role=Role.org_admin
  table.raw.each do |row|
    admin = Factory(:user, :email => row[0])
    jurisdiction = Jurisdiction.find_by_name(row[1]) || Factory(:jurisdiction, :name => row[1])
    RoleMembership.create!(:user => admin, :jurisdiction => jurisdiction, :role => admin_role)
  end
end

Given /^"([^\"]*)" is an unconfirmed user$/ do |email|
  user = User.find_by_email(email) || Factory(:user, :email => email, :email_confirmed => false)
  user.email_confirmed = false
  user.save
end

Given /^(.*) has the following administrators:$/ do |jurisdiction_name, table|
  role = Role.admin
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  table.raw.each do |row|
    first_name, last_name = row.first.split(/\s+/)
    user = Factory(:user, :first_name => first_name, :last_name => last_name, :email => row.last)
    user.role_memberships.create :role => Role.public, :jurisdiction => jurisdiction, :user => user
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

Given "a user in a non-public role" do
  role = Factory(:role, :approval_required => true)
  # the role membership factory also builds a user
  Factory(:role_membership, :role => role ).user
end

Given /^"([^\"]*)" is not public in "([^\"]*)"$/ do |user_email, jurisdiction_name|
  user=User.find_by_email(user_email)
  role=Role.public
  jurisdiction=Jurisdiction.find_by_name!(jurisdiction_name)
  role_membership=user.role_memberships.find_by_role_id_and_jurisdiction_id(role.id,jurisdiction.id)
  role_membership.destroy if !role_membership.nil?
end

When /^I sign up for an account as "([^\"]*)"$/ do |email|
  visit new_user_path
  fill_in_user_signup_form("Email" => email, 
    "Home Jurisdiction" => "Texas", 
    "What is your primary role" => "Health Alert and Communications Coordinator", 
    "Are you a public health professional?" => "checked"
  )
  click_button "Sign Up"
end

When /^I create a user account with the following info:$/ do |table|
  visit new_admin_user_path
  fill_in_user_signup_form(table)
  click_button "Save"
end

When 'I signup for an account with the following info:' do |table|
  visit new_user_path
  fill_in_user_signup_form(table)  
  click_button 'Sign Up'
end

When /^I log in as "([^\"]*)"$/ do |user_email|
  login_as User.find_by_email!(user_email)
end

When /^I sign in with "([^\"]*)" and "([^\"]*)"$/ do |email, password|
  visit sign_in_path
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button "Sign in"
end

When /^"([^\"]*)" clicks the confirmation link in the email$/ do |user_email|
  email = ActionMailer::Base.deliveries.last
  user = User.find_by_email!(user_email)
  link = user_confirmation_url(user, user.token, :host => HOST)
  email.body.include?(link).should be_true
  link = user_confirmation_url(user, user.token, :host => "#{page.driver.rack_server.host}:#{page.driver.rack_server.port}")
  visit link
end

When /^I import the user file "([^\"]*)" with options "([^\"]*)"$/ do |filename, options|
  create = (options=~/create/i).nil? ? false : true
  update = (options=~/update/i).nil? ? false : true
  $stderr = StringIO.new
  UserImporter.import_users(File.join(Rails.root, 'tmp', filename),
                            :default_jurisdiction => Jurisdiction.find_by_name("Texas"),
                            :create => create,
                            :update => update
      )
  When(%Q{delayed jobs are processed})
end

When /^I fill out the delete user form with "([^\"]*)"$/ do |user_ids|
  user_ids.split(',').each { |name| fill_in_fcbk_control(name) }
end

Then '"$email" should have the "$role" role for "$jurisdiction"' do |email, role, jurisdiction|
  p = User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = p.role_memberships.find_by_role_id_and_jurisdiction_id(r.id, j.id)
  m.should_not be_nil
end

Then '"$email" should have the "$role" role request for "$jurisdiction"' do |email, role, jurisdiction|
  p = User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = RoleRequest.find_by_role_id_and_jurisdiction_id_and_user_id(r.id, j.id, p.id)
  m.should_not be_nil
end

Then '"$email" should not have the "$role" role request for "$jurisdiction"' do |email, role, jurisdiction|
  p = User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = RoleRequest.find_by_role_id_and_jurisdiction_id_and_user_id(r.id, j.id, p.id)
  m.should be_nil
end

Then '"$email" should not exist' do |email|
  User.find_by_email(email).should be_nil
end

Then "standard error stream should be empty" do
  $stderr.string.should be_empty
end

Then "standard error stream should not be empty" do
  $stderr.string.should_not be_empty
end

When /^I attach the tmp file at "([^\"]*)" to "([^\"]*)"$/ do |path, field|
  full_path = "#{File.join(Rails.root,'tmp',path)}"
  page.execute_script("$(\"input[name='#{field}']\").css('opacity', '100')")
  attach_file(field, full_path)
end

When '"$email1" is deleted as a user by "$email2"' do |email1,email2|
  User.find_by_email(email1).delayed_delete_by(email2,"127.0.0.1")
end

When /^I maliciously post a destroy user "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  script = "var f = document.createElement('form'); " +
    "f.style.display = 'none'; " +
    "$('body').append(f); " +
    "f.method = 'POST'; " +
    "f.action = '/users_delete'; " +
    "var u = document.createElement('input'); " +
    "u.setAttribute('type', 'hidden'); " +
    "u.setAttribute('name', 'users[user_ids][]'); " +
    "u.setAttribute('value', '#{user.id}'); " +
    "f.appendChild(u); " +
    "f.submit();"
  page.execute_script(script)
end
