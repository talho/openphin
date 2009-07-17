Given "there is an unapproved $name organization" do |name|
  Factory(:organization, :name => name, :approved => false, :contact => Factory(:user))
end

When 'I signup for an organization account with the following info:' do |table|
  visit new_organization_path
  fill_in_signup_form(table)
  click_button 'Save'
end

Given /^the organization "([^\"]*)" has been approved$/ do |org_name|
  org=Organization.find_by_name(org_name)
  org.approved = true
  org.save!
end

When /^I approve the organization "([^\"]*)"$/ do |org_name|
  visit approve_admin_organization_path(Organization.find_by_name(org_name))
end

Then /^I should see the organization "([^\"]*)" is awaiting approval$/ do |org_name|
  organization=Organization.find_by_name(org_name)
  response.should have_selector(".pending_organization_requests") do |request|
    request.should have_selector(".request") do |org|
      org.should have_selector(".org_name", :content => org_name)
      org.should have_selector("a.approval_link[href='#{approve_admin_organization_path(organization)}']")
      org.should have_selector("a.denial_link[href='#{deny_admin_organization_path(organization)}']")
    end
  end
end

Then /^I should not see the organization "([^\"]*)" is awaiting approval$/ do |org_name|
  organization=Organization.find_by_name(org_name)
  response.should_not have_selector(".pending_organization_requests .request .org_name", :content => org_name)
end

Then /^"([^\"]*)" contact should receive the following email:$/ do |org_name, table|
  contact=Organization.find_by_name(org_name).contact
  Then "\"#{contact.email}\" should receive the email:", table
  
end