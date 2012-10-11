@ext
Feature: Organization Folders

  To share and manage documents within an organization
  As an organization admin
  I would like to have an organization folder and subfolders
  
  # We've already tested the creation of the organization folder in the organization manager, this is just for managing folders
  Background:
    Given I have users for organization folders
    And I have an organiztion with a contact
    And I am logged in as an organization contact
  
  Scenario: I have admin rights
    Given I am an organization admin
    Then I am an admin for the organization folder

  Scenario: Create a new folder    
    And I create a folder under the organization folder
    Then I should see an organization sub folder
    And I am an admin for the organization sub folder
     
  Scenario: Create a folder, override audience
    Given I have folder "SUB" under organization "ORG"
    When I override the organization sub folder audience
    Then I am an admin for the oranization sub folder
    And I should see an organization sub folder
  
  Scenario: Create a not shared folder
    Given I have a not shared folder "SUB" under organization "ORG"    
    Then I should see an organization sub folder
    And I am an admin for the oranization sub folder   
    
  Scenario: Create a shared folder
    Given I have folder "SUB" under organization "ORG" with audience "test@example.com"
    Then I should see an organization sub folder
    And I am an admin for the oranization sub folder
         
  Scenario: Delete a folder under organization folder
    Given I have folder "SUB" under organization "ORG"
    When I delete an organization sub folder
    Then I should not see an organization sub folder
    
  Scenario: Move a folder under organization
    Given I have folder "SUBSUB" under organization "ORG"
    And I have folder "SUB" under organization "ORG"
    When I move an organization sub folder under an organization sub folder
    Then I see 3 levels of organization folders
    
  Scenario: Shouldn't see a folder with children, but not any that are shared with me
    Given "test@example.com" is a member of the organization "ORG"
    And I have a not shared folder "SUB" under organization "ORG"
    When I am logged in as an organization member
    Then I should not see an organization sub folder
    