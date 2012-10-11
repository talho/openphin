Given /^I am an organization admin$/ do
  assert Organization.find_by_name("ORG").contact.id == current_user.id
end

Then /^I am a folder admin for "([^\"]*)"$/ do |orgname|
  assert Folder.find_by_name(orgname).owner?(current_user)
end

Given /^I have (a not shared )?folder "([^\"]*)" under organization "([^\"]*)"(?: with audience "([^\"]*)")?$/ do |notshared, foldername, orgname, audience|
  org = Folder.find_by_name(orgname)
  folder = Folder.create :name => foldername, :organization_id => org.organization_id, :parent_id => org.id
  if notshared
    folder.audience_id = nil
    folder.save!
  end
  if audience
    folder.audience = Audience.new :user_ids => [User.find_by_email(audience).id]
    folder.save!
  end
  step %Q{I press "Refresh"}
end

Given /^I have users for organization folders$/ do
  step %Q{the following users exist:}, table(%{
    | Bo Duke   | bo@example.com       | Mechanic | Hazard County  |
    | Test Er   | test@example.com     | Dude     | Sizzle County  |
  })
end

Given /^I have an organiztion with a contact$/ do
  step %Q{an organization exist with the following info:}, table(%{
    | name               | ORG                                 |            
    | locality           | Austin                              |
    | state              | TX                                  |            
    | postal_code        | 787202                              |
    | street             | 123 Elm Street                      |
    | phone              | 888-555-1212                        |
    | description        | An org                              |
  })
  step %Q{"ORG" has "bo@example.com" as the contact}
end

Given /^I am logged in as an organization contact$/ do
  step %Q{I am logged in as "bo@example.com"}
  step %Q{I press "Documents"}
end

Then /^I am an admin for the organization folder$/ do
  step %Q{I am a folder admin for "ORG"}
end

Then /^I am an admin for the oranization sub folder$/ do
  step %Q{I am a folder admin for "SUB"}
end

And /^I create a folder under the organization folder$/ do
  step %Q{I select the "ORG" grid row within ".document-folder-tree-grid"}
  step %Q{I press "Add Folder"}
  step %Q{I fill in "Folder Name" with "SUB"}
  step %Q{I press "Save"}
end

Then /^I should see an organization sub folder$/ do
  begin
    step %Q{I expand the folders "ORG"}
  rescue
  end 
  step %Q{I should see "ORG" in grid row 2 within ".document-folder-tree-grid"}
  step %Q{I should see "SUB" in grid row 3 within ".document-folder-tree-grid"}
end

Then /^I am an admin for the organization sub folder$/ do
  step %Q{I am a folder admin for "SUB"}
end

Then /^I override the organization sub folder audience$/ do
  step %Q{I expand the folders "ORG"}
  step %Q{I select the "SUB" grid row within ".document-folder-tree-grid"}    
  step %Q{I click folder-context-icon on the "SUB" grid row}
  step %Q{I click x-menu-item "Edit Folder"}
  step %Q{I click x-tab-strip-text "Sharing"}
  step %Q{I choose "Shared - Accessible to the audience specified below"}
  step %Q{I select the following in the audience panel:} , table(%{
    | name          | type |
    | Test Er       | User |
  })
  step %Q{I press "Save"}
  step %Q{I wait for 2 seconds}
end

Then /^I delete an organization sub folder$/ do
  step %Q{I expand the folders "ORG"}
  step %Q{I select the "SUB" grid row within ".document-folder-tree-grid"} 
  step %Q{I click folder-context-icon on the "SUB" grid row}
  step %Q{I click x-menu-item "Delete Folder"}
  step %Q{I press "Yes"}
end

Then /^I should not see an organization sub folder$/ do
  step %Q{I should see "ORG" in grid row 2 within ".document-folder-tree-grid"}
  step %Q{I should not see "SUB" in grid row 3 within ".document-folder-tree-grid"}
end

Then /^I move an organization sub folder under an organization sub folder$/ do
  step %Q{I expand the folders "ORG"}
  step %Q{I select the "SUBSUB" grid row within ".document-folder-tree-grid"}     
  step %Q{I click documents-file-action-button "Move Selection"}    
  step %Q{I select "SUB" from ext combo "Move to"}
  step %Q{I press "Save"} 
end

Then /^I see 3 levels of organization folders$/ do
  step %Q{I should see "ORG" in grid row 2 within ".document-folder-tree-grid"}
  step %Q{I should see "SUB" in grid row 3 within ".document-folder-tree-grid"}
  step %Q{I should see "SUBSUB" in grid row 4 within ".document-folder-tree-grid"}
end

And /^I am logged in as an organization member$/ do
  step %Q{I am logged in as "test@example.com"}
  step %Q{I press "Documents"}
end

