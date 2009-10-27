Given /^"([^\"]*)" has requested to be a "([^\"]*)" for "([^\"]*)"$/ do |user_email, role_name, jurisdiction_name|
  user=User.find_by_email(user_email) || Factory(:user, :email => user_email)
  role=Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  jurisdiction = Jurisdiction.find_by_name(jurisdiction_name) ||  Factory(:jurisdiction, :name => jurisdiction_name)
  req = Factory(:role_request,
                    :jurisdiction => jurisdiction,
                    :role => role,
                    :user => user,
                    :requester => user)
end

Given /^"([^\"]*)" has approved the "([^\"]*)" role in "([^\"]*)" for "([^\"]*)"$/ do |admin_email_address, role_name, jurisdiction_name, email_address|
 Given "\"#{admin_email_address}\" has approved the \"#{role_name}\" role in \"#{jurisdiction_name}\" for \"#{email_address}\" 0 days ago"
end

Given /^"([^\"]*)" has approved the "([^\"]*)" role in "([^\"]*)" for "([^\"]*)" (\d) days ago$/ do |admin_email_address, role_name, jurisdiction_name, email_address, numdays|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  user = User.find_by_email(email_address)
  r = user.role_memberships << Factory(:role_membership, :user_id => user.id, :jurisdiction_id => jurisdiction.id, :role_id => role.id, :created_at => numdays.to_i.days.ago)
end

When /^I fill out the role request form with:$/ do |table|
  table.rows_hash.each do |label, value|
    case label
    when /Jurisdiction/i, /Role/i
      select value, :from => label
    else
      raise "The field '#{field}' is not supported, please update this step if you intended to use it"
    end
  end
  click_button 'Submit Request'
end

When /^I approve "([^\"]*)" in the role "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  visit approve_admin_role_request_path(request) 
end

When /^I deny "([^\"]*)" in the role "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  visit deny_admin_role_request_path(request)
end

Then /^I should see (\d*) pending role requests?$/ do |num|
  if(num.to_i == 0)
    response.should_not have_selector(".pending_role_requests .request")
  else
    response.should have_selector(".pending_role_requests .request")
  end
  current_user.role_requests.unapproved.flatten.size.should == num.to_i
end

When /^I maliciously post a deny for a role request for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  role_request = user.role_requests.first
  delete_via_redirect admin_role_request_path(role_request)
end

Then /^I should not see that "([^\"]*)" is awaiting approval$/ do |user_email|
  visit admin_role_requests_path
  response.should_not have_selector( ".pending_role_requests") do |req|
    req.should have_selector(".requester_email", :content => user_email)
  end
end

Then /^I should see that I have a pending role request$/ do
  current_user.role_requests.unapproved.should_not be_empty
end

Then /^I should see I am awaiting approval for (.*) in (.*)$/ do |role_name, jurisdiction_name|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  request = current_user.role_requests.unapproved.detect{ |request| request.jurisdiction == jurisdiction && request.role == role }
  request.should_not be_nil
  
  visit role_requests_path
  response.should have_selector( ".pending_role_requests") do |req|
    req.should contain(role_name)
    req.should contain(jurisdiction_name)
  end
end

Then /^I should see "([^\"]*)" is awaiting approval for "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)

  visit admin_role_requests_path
  response.should have_selector( ".pending_role_requests") do |req|
    req.should have_selector(".requester_email", :content => user_email)
    req.should have_selector(".role", :content => role_name)
    req.should have_selector(".jurisdiction", :content => current_user.jurisdictions.first.name )
    req.should have_selector("a.approve_link[href='#{approve_admin_role_request_path(request)}']")
    req.should have_selector("a.deny_link[href='#{deny_admin_role_request_path(request)}']")
  end
end

Then /^I should see (\d) recent role approvals?$/ do |num|
  if(num.to_i == 0)
    response.should_not have_selector(".recent_role_approvals .approval")
  else
    response.should have_selector(".recent_role_approvals .approval")
  end
  current_user.role_memberships.not_public_roles.recent.flatten.size.should == num.to_i
end

Then /^I can't test 'should redirect_to' because of webrat bug$/ do
  true
end