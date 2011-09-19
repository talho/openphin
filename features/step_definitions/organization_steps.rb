Given /^"([^\"]*)" is a member of the organization "([^\"]*)"$/ do |email, org_name|
	user = User.find_by_email(email) || Factory(:user, :email => email)
	org = Organization.find_by_name(org_name) || Factory(:organization, :name => org_name)
  org << user
  org.save!
  org.group.refresh_recipients(:force => true)
end

Given /^there is an unapproved "([^\"]*)" organization with "([^\"]*)" as the contact$/ do |name, email|
	contact = User.find_by_email(email) || Factory(:user, :email => email)
	Factory(:organization, :name => name, :approved => false)
end

Given "there is an unapproved $name organization" do |name|
	contact=Factory(:user)
	Given "there is an unapproved #{name} organization with \"#{contact.email}\" as the contact"
end

Given 'the following unapproved organizations exist:' do |table|
  table.hashes.each do |row|
    org = Factory(:organization, :name => row['name'], :distribution_email => row['distribution_email'], :contact_display_name => row['contact_name'], :contact_email => row['contact_email'])
    row['jurisdictions'].split(',').each do |name|
      org.organization_requests.create!(:jurisdiction_id => Jurisdiction.find_by_name(name.strip).id)
    end
  end
end

Given /^an organization exist with the following info:$/ do |table|
  Organization.create! table.rows_hash
end

Given /^the organization "([^\"]*)" has been approved$/ do |org_name|
  org=Organization.find_by_name(org_name)
  org.approved = true
  org.save!
end

Given /^"([^"]*)" has requested membership in organization "([^"]*)"$/ do |email, orgname|
  user = User.find_by_email(email)
  org = Organization.find_or_create_by_name(orgname)
  OrganizationMembershipRequest.new(:organization_id => org.id, :user_id => user.id, :requester_id => user.id).save!
end

# When 'I approve the "([^\"]*)" membership for "$email"' do |org_name, email|
#   user = User.find_by_email!(email)
#   organization = Organization.find_by_name!(org_name)
#   request = OrganizationMembershipRequest.find_by_organization_id_and_user_id(organization.id, user.id)
#   visit organization_membership_request_path(request.id, request.token)
# end

Given /^I approve the "([^\"]*)" membership for "([^\"]*)"$/ do |org_name, email|
  user = User.find_by_email!(email)
  organization = Organization.find_by_name!(org_name)
  request = OrganizationMembershipRequest.find_by_organization_id_and_user_id(organization.id, user.id)
  visit organization_membership_request_path(request.id, request.token)
end

When 'I signup for an organization account with the following info:' do |table|
  visit new_organization_path
  fill_in_signup_form(table)
  click_button 'Save'
end

When /^I approve the organization "([^\"]*)"$/ do |org_name|
  visit approve_admin_organization_path(Organization.find_by_name(org_name))
end

When /^I deny the organization "([^\"]*)"$/ do |org_name|
  visit deny_admin_organization_path(Organization.find_by_name(org_name))
end

When /^I click the organization membership request approval link in the email for "([^\"]*)"$/ do |user_email|
  email = ActionMailer::Base.deliveries.last
  user = User.find_by_email!(user_email)
  request = OrganizationMembershipRequest.find_by_user_id(user.id)
  link = admin_organization_membership_request_path(request.id)
  email.body.include?(link).should be_true
  link = admin_organization_membership_request_path(request.id, :host => "http://#{page.driver.rack_server.host}:#{page.driver.rack_server.port}")
  visit link
end

When /^"([^\"]*)" clicks the organization confirmation link in the email$/ do |user_email|
  email = ActionMailer::Base.deliveries.last
  organization = Organization.find_by_contact_email!(user_email)
  link = organization_confirmation_path(organization, organization.token)
  email.body.include?(link).should be_true
  link = organization_confirmation_path(organization, organization.token, :host => "http://#{page.driver.rack_server.host}:#{page.driver.rack_server.port}")
  visit link
end

When /^"([^\"]*)" receives a "([^\"]*)" organization approval email$/ do |user_email, name|
  When "delayed jobs are processed"
  email = ActionMailer::Base.deliveries.last
  organization = Organization.find_by_name!(name)
  email.subject.should contain("User requesting organization signup")
  link = admin_pending_requests_url(:host => HOST)
  email.body.include?(link).should be_true
end

When /^I maliciously post an approver id$/ do
  script = "elem = document.createElement('input'); " +
    "elem.setAttribute('name','[user][organization_membership_requests_attributes][0][approver_id]'); " +
    "elem.setAttribute('value','1'); " +
    "elem.setAttribute('type','hidden'); " +
    "$('form').append(elem);"
  page.execute_script(script)
end

When /^I maliciously attempt to remove "([^\"]*)" from "([^\"]*)"$/ do |email, org_name|
  user = User.find_by_email!(email)
  org = Organization.find_by_name!(org_name)
  script = "var f = document.createElement('form'); " +
    "f.style.display = 'none'; " +
    "$('body').append(f); " +
    "f.method = 'POST'; " +
    "f.action = '#{admin_organization_membership_request_path(:id => org.id, :user_id => user.id)}'; " +
    "var m = document.createElement('input'); " +
    "m.setAttribute('type', 'hidden'); " +
    "m.setAttribute('name', '_method'); " +
    "m.setAttribute('value', 'delete'); " +
    "f.appendChild(m); " +
    "f.submit();"
  page.execute_script(script)
end

Then /^I should see the organization "([^\"]*)" is awaiting approval for "([^\"]*)"$/ do |org_name, email|
  organization=Organization.find_by_name(org_name)
  current_user=User.find_by_email(email)
  response.should have_selector(".pending_organization_requests") do |request|
    request.should have_selector(".request") do |org|
      org.should have_selector(".org_name", :content => org_name)
      org.should have_selector("a.approval_link[href='#{approve_admin_organization_request_path(organization.organization_requests.in_jurisdictions(current_user.jurisdictions))}']")
      org.should have_selector("a.denial_link[href='#{deny_admin_organization_request_path(organization.organization_requests.in_jurisdictions(current_user.jurisdictions))}']")
    end
  end
end

Then /^I should not see the organization "([^\"]*)" is awaiting approval$/ do |org_name|
  organization=Organization.find_by_name(org_name)
  response.should_not have_selector(".pending_organization_requests .request .org_name", :content => org_name)
end

Then /^"([^\"]*)" contact should receive the following email:$/ do |org_name, table|
  org=Organization.find_by_name(org_name)
  if org.contact.blank?
    Then "\"#{org.contact_email}\" should receive the email:", table
  else
    Then "\"#{org.contact.email}\" should receive the email:", table
  end
end

Then /^I should not see "(.*)" organization as an option$/ do |name|
  organization = Organization.find_by_name!(name)
  response.should_not have_selector("select[name*=organization_id] option", :value => organization.id.to_s)
end

Then '"$organization" is confirmed' do |name|
  organization = Organization.find_by_name!(name)
  organization.confirmed?.should_not be_nil
end

Then /^there is a "([^\"]*)" organization that is unapproved$/ do |name|
  organization = Organization.find_by_name!(name)
  organization.organization_requests.should_not be_empty
  organization.approved?.should_not be_nil
  organization.approved?.should == false
end

When /^I import the organization file "([^\"]*)"$/ do |filename|
  OrgImporter.import_orgs(File.join(Rails.root, 'tmp', filename))
end
