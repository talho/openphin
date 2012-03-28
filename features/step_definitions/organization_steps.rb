Given /^"([^\"]*)" is a member of the organization "([^\"]*)"$/ do |email, org_name|
	user = User.find_by_email(email) || FactoryGirl.create(:user, :email => email)
	org = Organization.find_by_name(org_name) || FactoryGirl.create(:organization, :name => org_name)
  org << user
  org.save!
end

Given /^an organization exist with the following info:$/ do |table|
  Organization.create! table.rows_hash
end

Given /^"([^"]*)" has requested membership in organization "([^"]*)"$/ do |email, orgname|
  user = User.find_by_email(email)
  org = Organization.find_or_create_by_name(orgname)
  OrganizationMembershipRequest.new(:organization_id => org.id, :user_id => user.id, :requester_id => user.id).save!
end

Given /^a few organizations$/ do
  3.times do |i|
    FactoryGirl.create(:organization)
  end
end

# Checks to see if organizations created via 'a few organizations' are in the grid
Then /^I should see organizations in the grid$/ do
  arr = [%w{name}] | Organization.all.map{|o| [o.name] }
  Then %Q{the grid ".org-list-grid" should contain:}, table(arr)
end

When /^I click on an organization$/ do
  When %Q{I wait for the "Loading..." mask to go away}
  When %Q{I click x-grid3-cell "#{Organization.order('updated_at').last.name}"}
end

Then /^I should see the organization details$/ do
  org = Organization.order('updated_at').last
  steps %Q{
    When I wait for the "Loading..." mask to go away
    Then I should see "Organization Detail"
     And I should see "#{org.name}"
     And I should see "#{org.email}"
     And I should see "#{org.description}"
     And I should see "P: #{org.phone}"
     And I should see "F: #{org.fax}"
     And I should see "#{org.street}"
     And I should see "#{org.locality}, #{org.state} #{org.postal_code}"
  }  
end

When /^I fill in the organization form$/ do
  steps %Q{
    When I fill in "Name" with "My Organization"
     And I fill in "E-mail" with "my@example.com"
     And I fill in "Description" with "This is a descriptive org"
     And I fill in "Phone" with "555-555-5555"
     And I fill in "Fax" with "555-555-5554"
     And I fill in "Street" with "1111 1st Street"
     And I fill in "Locality" with "Austin"
     And I fill in "State" with "Tx"
     And I fill in "Postal Code" with "78701"
  }
end

When /^I give the organization an audience$/ do
  #Select the first jurisdiction, first role, last user
  When %Q{I select the following in the audience panel:}, table(%{
      | name                      | type         |
      | #{Jurisdiction.first}     | Jurisdiction |
      | #{Role.first}             | Role         |
      | #{User.last.display_name} | User         |
  })
end

Then /^I should have a new organization$/ do
  When %Q{I wait for the "Saving..." mask to go away}
  org = Organization.order('updated_at').last
  org.should_not be_nil
  org.name.should == "My Organization"
  org.email.should == "my@example.com"
  org.description.should == "This is a descriptive org"
  org.phone.should == "555-555-5555"
  org.fax.should == "555-555-5554"
  org.street.should == "1111 1st Street"
  org.locality.should == "Austin"
  org.state.should == "Tx"
  org.postal_code.should == "78701"
end

Then /^my organization should have some recipients$/ do
  Organization.order('updated_at').last.group.recipients.include?(User.last).should be_true
  Organization.order('updated_at').last.group.recipients.include?(RoleMembership.find_by_jurisdiction_id_and_role_id(Jurisdiction.first.id, Role.first.id).user).should be_true
end

Then /^my organization should have a folder$/ do
  folder = Folder.find_by_name(Organization.order('updated_at').last.name)
  folder.should_not be_nil
  (folder.audience.recipients - Organization.order('updated_at').last.group.recipients).should be_empty
end

Then /^the required organization fields should be invalid$/ do
  Then %Q{the "Name" field should be invalid}
  Then %Q{the "Description" field should be invalid}
  Then %Q{the "Locality" field should be invalid}
end

When /^I edit an organization$/ do
  When %Q{I click editBtn on the "#{Organization.order('updated_at').last.name}" grid row}
  And %Q{I wait for the "Loading..." mask to go away}
end

Then /^my organization should be updated$/ do
  # This fills in the same values as the new organization, so we need to make sure it matches up
  Then "I should have a new organization"
end

When /^I delete an organization$/ do
  @del_org_name = Organization.order('updated_at').first.name
  @org_count = Organization.count
  When "I will confirm on next step"
  When %Q{I click removeBtn on the "#{Organization.order('updated_at').first.name}" grid row}
  And %Q{I wait for the "Loading..." mask to go away}
end

Then /^my organization shouldn't exist$/ do
  Organization.find_by_name(@del_org_name).should be_nil
  @org_count.should == Organization.count + 1
end

Given /^I am a member of an organization$/ do
  Given %Q{"#{current_user.email}" is a member of the organization "#{Organization.order('updated_at').first.name}"}
end

Given /^a few organization membership requests( for a different organization)?$/ do |diff|
  org = diff.nil? ? Organization.order('updated_at').first : Organization.order('updated_at').last
  Given %Q{"#{User.last.email}" has requested membership in organization "#{org.name}"}
  
  # save off the org request state
  @org_reqs ||= []
  @org_reqs << {:user => User.last, :org => org}
end

Then /^I should( not)? see organization membership requests$/ do |neg|
  if neg
    Then %Q{I should see "There are no unapproved requests at this time."}
  else
    Then %Q{I should see "Default FactoryUser"}
    Then %Q{I should see "ApproveDeny"}
  end
end

Then /^my organization should( not)? have a new member$/ do |neg|
  When %Q{I wait for the "Loading..." mask to go away}
  
  org = current_user.organizations.first

  if neg.nil?
    (org.group.recipients - [current_user]).should_not be_empty
  else
    (org.group.recipients - [current_user]).should be_empty
  end
end

Then /^the organization request should be deleted$/ do
  omr = OrganizationMembershipRequest.first(:conditions => {:user_id => @org_reqs.last[:user].id, :organization_id => @org_reqs.last[:org].id, :approver_id => nil})
  omr.should be_nil
end

