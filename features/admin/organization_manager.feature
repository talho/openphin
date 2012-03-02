@ext
Feature: Organization Manager

  To create and edit organizations
  As an admin
  I want a management panel
  
  Background:
    Given I am logged in as a superadmin
    
  Scenario: View a list of organizations
    Given I have organizations
    When I navigate to the manage organizations tab
    Then I should see organizations in the grid
      
  Scenario: View details of an organization
    Given I have organizations
    When I navigate to the manage organizations tab
     And I click on an organization
    Then I should see the organization details
  
  Scenario: Create an organization, check for folder
    When I navigate to the manage organizations tab
     And I press "New Organization"
     And I fill in the organization form
     And I press "Save"
    Then I should have a new organization
     And that organization should have a folder
     
  Scenario: Test validations
  
  Scenario: Edit an organization, check for folder
  
  Scenairo: Change organization name, check for folder
  
  Scenario: Delete organization
