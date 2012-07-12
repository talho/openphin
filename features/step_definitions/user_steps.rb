Given "a user named $name" do |name|
  first_name, last_name = name.split
  User.find_by_first_name_and_last_name(first_name, last_name) ||
    FactoryGirl.create(:user, :first_name => first_name, :last_name => last_name)
end 

Given 'a user with the email "$email"' do |email|
  User.find_by_email(email) || FactoryGirl.create(:user, :email => email)
end

Given /^the user "([^"]*)" with the email "([^"]*)" has the role "([^"]*)"(?: application "([^"]*)")? in "([^"]*)"$/ do |name, email, role, app_name, jurisdiction|
  first_name, last_name = name.split
  jur_obj = Jurisdiction.find_or_create_by_name(jurisdiction.to_s)
  unless (user = User.find_by_email(email))
    #create the user.  this results in a Public role in the requested jurisdiction, and a role request for 'role'
    user = FactoryGirl.create(:user, :first_name => first_name, :last_name => last_name, :email => email, :home_jurisdiction_id => jur_obj.id)#, :role_requests_attributes => [{:jurisdiction_id => jur_obj.id, :role_id => role_obj.id }] )
  end
  roles = role.split(',').map(&:strip)
  app_name = app_name.blank? ? 'phin' : app_name
  roles.each do |r|
    app = step %Q{an app named "#{r.to_s == 'SysAdmin' ? 'system' : app_name}"}
    role_obj = Role.find_by_name_and_app_id(r.to_s,app.id) || FactoryGirl.create(:role, :name => r.to_s, :public => r.to_s == "Public", :application => app.name)
    unless RoleMembership.already_exists?(user, role_obj, jur_obj)
      # do this manually, it's potentially faster than the factory method.
      RoleMembership.create :role_id => role_obj.id, :jurisdiction_id => jur_obj.id, :user_id => user.id
    end
  end
end

Given /^"([^\"]*)" has the password "([^\"]*)"$/ do |email, password|
  u=User.find_by_email(email)
  u.update_password(password)
  u.save
end

Given /^the following users exist:$/ do |table|
  table.raw.each do |row|
    step %Q{the user "#{row[0]}" with the email "#{row[1]}" has the role "#{row[2]}"#{row[4].blank? ? '' : " application \"#{row[4]}\""} in "#{row[3]}"}
  end
end

Given /^(\d+) users exist like$/ do |mob_count, table|
  # table format: | role         | [role]         |
  #               | jurisdiction | [jurisdiction] |
  mobber = 0
  while mobber < mob_count.to_i do
    user_name = "mobuser #{table.rows_hash["role"]+ mobber.to_s}"
    user_email = "#{table.rows_hash["role"] + mobber.to_s}@example.com"
    application = table.rows_hash['application'].blank? ? '' : " application \"#{table.rows_hash['application']}\""
    step %Q{the user "#{user_name}" with the email "#{user_email}" has the role "#{table.rows_hash["role"]}"#{application} in "#{table.rows_hash["jurisdiction"]}"}
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
  step %Q{I am logged in}
end

Then /^I am logged in$/ do
  @current_user.should_not be_nil
  begin
    page.should have_no_css('#loading-mask', :visible => true)
  rescue Selenium::WebDriver::Error::ObsoleteElementError
    # this is a stale element error meaning between us finding the element and us processing, it disappeared. In this case, it's good
    true
  end
end

Given /^"([^\"]*)" is allowed to send alerts$/ do |email|
  user = User.find_by_email(email)
  user.role_memberships(:role => FactoryGirl.create(:role, :alerter => true), :jurisdiction => FactoryGirl.create(:jurisdiction))
end

Given 'I am allowed to send alerts' do
  current_user.role_memberships(:role => FactoryGirl.create(:role, :alerter => true), :jurisdiction => FactoryGirl.create(:jurisdiction))
end

Given 'I have confirmed my account for "$email"' do |email|
  user = User.find_by_email!(email)
  visit new_user_confirmation_path(:user_id => user.id, :token => user.confirmation_token, :encode => false)
end

Given "the following administrators exist:" do |table|
  admin_role = Role.admin
  table.raw.each do |row|
    admin = FactoryGirl.create(:user, :email => row[0])
    jurisdiction = Jurisdiction.find_by_name(row[1]) || FactoryGirl.create(:jurisdiction, :name => row[1])
    admin.role_memberships.each do |rm|
      rm.destroy
    end
    RoleMembership.create!(:user => admin, :jurisdiction => jurisdiction, :role => admin_role)
  end
end

Given "the following organization administrators exist:" do |table|
  admin_role=Role.org_admin
  table.raw.each do |row|
    admin = FactoryGirl.create(:user, :email => row[0])
    jurisdiction = Jurisdiction.find_by_name(row[1]) || FactoryGirl.create(:jurisdiction, :name => row[1])
    RoleMembership.create!(:user => admin, :jurisdiction => jurisdiction, :role => admin_role)
  end
end

Given /^"([^\"]*)" is an unconfirmed user$/ do |email|
  user = User.find_by_email(email) || FactoryGirl.create(:user, :email => email, :email_confirmed => false)
  user.email_confirmed = false
  user.save
end

Given /^(.*) has the following administrators:$/ do |jurisdiction_name, table|
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  table.raw.each do |row|
    app = row[2].blank? ? 'phin' : row[2]
    role = Role.admin(app)
    first_name, last_name = row.first.split(/\s+/)
    user = FactoryGirl.create(:user, :first_name => first_name, :last_name => last_name, :email => row[1])
    user.role_memberships.create :role => Role.public(app), :jurisdiction => jurisdiction, :user => user
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
  role = FactoryGirl.create(:role, public: false)
  # the role membership factory also builds a user
  FactoryGirl.create(:role_membership, :role => role ).user
end

Given /^"([^\"]*)" is not public in "([^\"]*)"$/ do |user_email, jurisdiction_name|
  user=User.find_by_email(user_email)
  role=Role.public
  jurisdiction=Jurisdiction.find_by_name!(jurisdiction_name)
  role_membership=user.role_memberships.find_by_role_id_and_jurisdiction_id(role.id,jurisdiction.id)
  role_membership.destroy if !role_membership.nil?
end

Given /^"([^\"]*)" is not public in app "([^\"]*)"$/ do |user_email, app|
  user=User.find_by_email(user_email)
  role=Role.public(app)
  role_memberships = user.role_memberships.where(role_id: role)
  role_memberships.each(&:destroy)
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
  step %Q{I sign out}
  visit new_user_path
  fill_in_user_signup_form(table)  
  click_button 'Sign Up'
end

When /^I log in as "([^\"]*)"$/ do |user_email|
  step %Q{I am logged in as "#{user_email}"}
end

When /^I sign in with "([^\"]*)" and "([^\"]*)"$/ do |email, password|
  visit sign_in_path
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button "Sign in"
end

When /^"([^\"]*)" clicks the confirmation link in the email$/ do |user_email|
  # email = ActionMailer::Base.deliveries.last
  # user = User.find_by_email!(user_email)
  # link = new_user_confirmation_url(:user_id => user.id, :token => user.confirmation_token, :encode => false, :host => HOST)
  # email.body.include?(link).should be_true
  # link = new_user_confirmation_url(:user_id => user.id, :token => user.confirmation_token, :encode => false, :host => "#{page.driver.rack_server.host}:#{page.driver.rack_server.port}")
  # visit link
end

When /^I import the user file "([^\"]*)" with options "([^\"]*)"$/ do |filename, options|
  create = (options=~/create/i).nil? ? false : true
  update = (options=~/update/i).nil? ? false : true
  $stderr = StringIO.new
  UserImporter.import_users(File.join(Rails.root.to_s, 'tmp', filename),
                            :default_jurisdiction => Jurisdiction.find_by_name("Texas"),
                            :create => create,
                            :update => update
      )
  step(%Q{delayed jobs are processed})
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
  full_path = "#{File.join(Rails.root.to_s,'tmp',path)}"
  page.execute_script("$(\"input[name='#{field}']\").css('opacity', '100')")
  attach_file(field, full_path)
end

When '"$email1" is deleted as a user by "$email2"' do |email1,email2|
  User.find_by_email(email1).destroy
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

Then /^"([^"]*)" should be confirmed$/ do |email|
  User.find_by_email(email).email_confirmed?.should be_true
end

Given /^I am logged in as a sysadmin/ do
  step %Q{the following entities exists:}, table([
    %w{ Jurisdiction Texas}
  ])
  step %Q{the following users exist:}, table(%{
    | Its Me |  me@example.com | SysAdmin | Texas |
  })
  step %Q{I am logged in as "me@example.com"}  
end

Given /^I am logged in as a superadmin$/ do
  step %Q{the following entities exists:}, table([
    %w{ Jurisdiction Texas}
  ])
  step %Q{the following users exist:}, table(%{
    | Its Me |  me@example.com | SuperAdmin | Texas |
  })
  step %Q{I am logged in as "me@example.com"}  
end

Given /^I am logged in as an admin$/ do
  step %Q{the following entities exists:}, table([
    %w{ Jurisdiction Texas}
  ])
  step %Q{the following users exist:}, table(%{
    | Its Me |  me@example.com | Admin | Texas |
  })
  step %Q{I am logged in as "me@example.com"}  
end

Given /^I am logged in as a public user/ do
  step %Q{the following entities exists:}, table([
    %w{ Jurisdiction Texas}
  ])
  step %Q{the following users exist:}, table(%{
    | Its Me |  me@example.com | Public | Texas |
  })
  
  step %Q{I am logged in as "me@example.com"}  
end

Given /^a few users with various roles$/ do
  3.times do |i|
    u = FactoryGirl.create(:user)
    u.role_memberships << RoleMembership.new(:role => Role.for_app('phin').all[i], :jurisdiction => Jurisdiction.all[i]) 
    u.save
  end
  step "delayed jobs are processed"
end
