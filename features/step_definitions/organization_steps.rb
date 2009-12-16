Given /^there is an unapproved "([^\"]*)" organization with "([^\"]*)" as the contact$/ do |name, email|
	contact = User.find_by_email(email) || Factory(:user, :email => email)
	Factory(:organization, :name => name, :approved => false, :contact_email => email)
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

Given /^the organization "([^\"]*)" has been approved$/ do |org_name|
  org=Organization.find_by_name(org_name)
  org.approved = true
  org.save!
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

When /^"([^\"]*)" clicks the organization confirmation link in the email$/ do |user_email|
  email = ActionMailer::Base.deliveries.last
  organization = Organization.find_by_contact_email!(user_email)
  link = organization_confirmation_path(organization, organization.token)
  email.body.should contain(link)
  visit link
end

When /^"([^\"]*)" receives a "([^\"]*)" organization approval email$/ do |user_email, name|
  When "delayed jobs are processed"
  email = ActionMailer::Base.deliveries.last
  organization = Organization.find_by_name!(name)
  email.subject.should contain("User requesting organization signup")
  link = admin_pending_requests_url(:host => HOST)
  email.body.should contain(link)
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