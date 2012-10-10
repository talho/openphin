@ext
Feature: Organization Folders

  To share and manage documents within an organization
  As an organization admin
  I would like to have an organization folder and subfolders
  
  # We've already tested the creation of the organization folder in the organization manager, this is just for managing folders
  Background:
    And the following users exist:
      | Bo Duke   | bo@example.com       | Mechanic | Hazard County  |
      | Test Er   | test@example.com     | Dude     | Sizzle County  |
    And an organization exist with the following info:
      | name               | ORG                                 |            
      | locality           | Austin                              |
      | state              | TX                                  |            
      | postal_code        | 787202                              |
      | street             | 123 Elm Street                      |
      | phone              | 888-555-1212                        |
      | description        | An org                              |
    And "ORG" has "bo@example.com" as the contact
    And I am logged in as "bo@example.com"
    And I press "Documents"
  
  Scenario: I have admin rights
    Given I am an organization admin for "ORG"
    Then I am a folder admin for "ORG"

  Scenario: Create a new folder    
    When I select the "ORG" grid row within ".document-folder-tree-grid"
    And I press "Add Folder"
    And I fill in "Folder Name" with "SUB"
    And I press "Save"
    Then I should see "ORG" in grid row 2 within ".document-folder-tree-grid"
    And I should see "SUB" in grid row 3 within ".document-folder-tree-grid"
    And I am a folder admin for "SUB"
     
  Scenario: Create a folder, override audience
    Given I have folder "SUB" under organization "ORG"
    And I expand the folders "ORG"
    When I select the "SUB" grid row within ".document-folder-tree-grid"    
    And I click folder-context-icon on the "SUB" grid row
    And I click x-menu-item "Edit Folder"
    And I click x-tab-strip-text "Sharing"
    And I choose "Shared - Accessible to the audience specified below"
    And I select the following in the audience panel:
      | name          | type |
      | Test Er       | User |
    And I press "Save"
    And I wait for 3 seconds
    And I am a folder admin for "SUB"
    And I can see the folder
  
  Scenario: Create a not shared folder
    Given I have a not shared folder "SUB" under organization "ORG"    
    Then I expand the folders "ORG"    
    And I should see "SUB" in grid row 3 within ".document-folder-tree-grid"
    And I am a folder admin for "SUB"    
    
  Scenario: Create a shared folder
    Given I have folder "SUB" under organization "ORG" with audience "test@example.com"
    Then I expand the folders "ORG"    
    And I should see "SUB" in grid row 3 within ".document-folder-tree-grid"
    And I am a folder admin for "SUB"
         
  Scenario: Delete a folder under organization folder
    Given I have folder "SUB" under organization "ORG"
    And I expand the folders "ORG"
    When I select the "SUB" grid row within ".document-folder-tree-grid" 
    And I click folder-context-icon on the "SUB" grid row
    And I click x-menu-item "Delete Folder"
    And I press "Yes"
    Then I should see "ORG" in grid row 2 within ".document-folder-tree-grid"
    And I should not see "SUB" in grid row 3 within ".document-folder-tree-grid"
    
  Scenario: Move a folder under organization
    Given I have folder "SUBSUB" under organization "ORG"
    Given I have folder "SUB" under organization "ORG"
    And I expand the folders "ORG"
    When I select the "SUBSUB" grid row within ".document-folder-tree-grid"     
    And I click documents-file-action-button "Move Selection"    
    When I select "SUB" from ext combo "Move to"
    And I press "Save"    
    Then I should see "ORG" in grid row 2 within ".document-folder-tree-grid"
    Then I should see "SUB" in grid row 3 within ".document-folder-tree-grid"
    Then I should see "SUBSUB" in grid row 4 within ".document-folder-tree-grid"    
    
  Scenario: Shouldn't see a folder with children, but not any that are shared with me
    Given "test@example.com" is a member of the organization "ORG"
    Given I have a not shared folder "SUB" under organization "ORG"
    And I am logged in as "test@example.com"
    And I press "Documents"
    Then I should see "ORG" in grid row 2 within ".document-folder-tree-grid"
    And I should not see "SUB" in grid row 3 within ".document-folder-tree-grid"
    