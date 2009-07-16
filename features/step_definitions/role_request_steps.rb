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

Then /^I should see that I have a pending role request$/ do
  current_user.role_requests.should_not be_empty
end
Given /^"([^\"]*)" has requested to be a "([^\"]*)" for "([^\"]*)"$/ do |user_email, role_name, jurisdiction_name|
  user=User.find_by_email(user_email) || Factory(:user, :email => user_email)
  role=Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  jurisdiction = Jurisdiction.find_by_name(jurisdiction_name) ||  Factory(:jurisdiction, :name => jurisdiction_name)
  req = Factory(:role_request,
                    :jurisdiction => jurisdiction,
                    :role => role,
                    :requester => user)
end

Then /^I should see "([^\"]*)" is awaiting approval for "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_requester_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  #login_as Jurisdiction.find_by_name(juris_name).admins.first
  visit role_requests_path
  response.should have_selector( ".pending_role_requests") do |req|
    req.should have_selector(".requester_email")
    req.should have_selector(".role")
    req.should have_selector(".jurisdiction")
    req.should have_selector("a.approve_link[href='#{approve_role_request_path(request)}']")
    req.should have_selector("a.deny_link[href='#{deny_role_request_path(request)}']")
  end
end

When /^I approve "([^\"]*)" in the role "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_requester_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  visit approve_role_request_path(request) 
end
