@ext
Feature: Organization Folders

  To share and manage documents within an organization
  As an organization admin
  I would like to have an organization folder and subfolders
  
  # We've already tested the creation of the organization folder in the organization manager, this is just for managing folders
  Background:
    Given I am logged in as an admin
  
  Scenario: I have admin rights
    Given I am an organization admin
    Then I am a folder admin for my organization
    
  Scenario: Create a new folder
    Given I am an organization admin
    When I create a folder under my organization
    Then my new folder exists under my organization folder
     And I am an admin for my new folder
     
  Scenario: Create a folder, override audience
    Given I am an organization admin
    When I create a folder under my organization with a different audience
    Then my new folder exists under my organization folder
     And I am an admin for my new folder
     
  Scenario: Delete a folder under organization folder
    Given I am an organization admin
     And I have a folder under my organization
    When I delete the folder under my organization
    Then I shouldn't have a folder under my organization
    
  Scenario: Move a folder under organization
    Given I an an organization admin
     And I have a bunch of folders under my organization
    When I move a folder to another folder under my organization
    Then my folder should be under the other folder under my organization
    
  Scenario: Shouldn't see a folder with children, but not any that are shared with me
    Given I am an organization member
     And I have a folder under my organization
     And I that other organization folder is not shared with me
    Then my organization folder should be marked as a leaf.