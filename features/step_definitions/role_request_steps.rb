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
    page.should_not have_css(".pending_role_requests .request")
  else
    page.should have_css(".pending_role_requests .request")
  end
  current_user.role_requests.unapproved.flatten.size.should == num.to_i
end

Then /^"([^"]*)" should( not)? have the role "([^"]*)" in "([^"]*)"$/ do |email, neg, role, jur|
  expectation = neg.nil? ? 1 : 0
  RoleMembership.find(:all, :conditions=>{:user_id=>User.find_by_email(email).id, :role_id=>Role.find_by_name(role).id, :jurisdiction_id=>Jurisdiction.find_by_name(jur).id }).count.should == expectation
end

When /^I maliciously post a delete for a role request for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  role_request = user.role_requests.first
  script = "elem = document.createElement('a'); " +
    "elem.setAttribute('href','#{admin_role_request_path(role_request)}'); " +
    destroy_link_onclick("confirm('Are you sure you want to delete this group?')") +
    "elem.innerHTML = 'Remove Role Request'; " +
    "$('body').append(elem);"
  page.execute_script(script)
  page.click_link("Remove Role Request")
end

When /^I maliciously post an approve for a role request for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  role_request = user.role_requests.first
  visit approve_admin_role_request_path(role_request)
end

When /^I maliciously post a deny for a role request for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  role_request = user.role_requests.first
  visit deny_admin_role_request_path(role_request)
end

Then /^I should not see that "([^\"]*)" is awaiting approval$/ do |user_email|
  visit admin_role_requests_path
	page.should have_css( ".pending_role_requests")
  page.should_not have_css(".requester_email", :content => user_email)
end

Then /^I should see that I have a pending role request$/ do
  current_user.role_requests.unapproved.should_not be_empty
end

Then /^I should have no pending role requests$/ do
  current_user.role_requests.unapproved.should be_empty
end

Then /^"([^\"]*)" should have no pending role requests$/ do | email |
  User.find_by_email(email).role_requests.unapproved.should be_empty
end

Then /^"([^\"]*)" should have a pending role request$/ do | email |
  User.find_by_email(email).role_requests.unapproved.should_not be_empty
end

Then /^I should see I am awaiting approval for (.*) in (.*)$/ do |role_name, jurisdiction_name|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  request = current_user.role_requests.unapproved.detect{ |request| request.jurisdiction == jurisdiction && request.role == role }
  request.should_not be_nil
  
  visit new_role_request_path
  within(:css, ".pending_role_requests") do
    page.should have_content(role_name)
    page.should have_content(jurisdiction_name)
  end
end

Then /^I should see "([^\"]*)" is awaiting approval for "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)

  visit admin_role_requests_path
  page.should have_css(".pending_role_requests .requester_email", :content => user_email)
  page.should have_css(".pending_role_requests .role", :content => role_name)
  page.should have_css(".pending_role_requests .jurisdiction", :content => current_user.jurisdictions.first.name )
  page.should have_css(".pending_role_requests a.approve_link[href='#{approve_admin_role_request_path(request)}']")
  page.should have_css(".pending_role_requests a.deny_link[href='#{deny_admin_role_request_path(request)}']")
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

Given /^I maliciously request the role "([^"]*)" in "([^"]*)"$/ do |role, jur|
  rhashes = []
  current_user.role_memberships.each{|rm|
    rid = rm.role_id
    jid = rm.jurisdiction_id
    rhashes.push({:id=>rm.id, :role_id=>rid, :jurisdiction_id=>jid,:rname=>Role.find(rid).name, :jname=>Jurisdiction.find(jid).name, :state=>'unchanged' })
  }
  role = Role.find_by_name(role)
  jur = Jurisdiction.find_by_name(jur)
  rhashes.push({:id=>-1, :role_id=>role.id, :jurisdiction_id=>jur.id, :rname=> role.name, :jname=> jur.name, :state=>"new"})
  When "I maliciously put data to \"/users/#{current_user.id}/profile.json\"", table(%{
    | user[rq] | #{ActiveSupport::JSON.encode(rhashes)} |
  })
end

