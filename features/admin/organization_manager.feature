@ext
Feature: Organization Manager

  To create and edit organizations
  As an admin
  I want a management panel
  
  Background:
   Given I am logged in as a superadmin
    
  Scenario: View a list of organizations
   Given a few organizations
    When I navigate to the manage organizations tab
    Then I should see organizations in the grid
      
  Scenario: View details of an organization
   Given a few organizations
    When I navigate to the manage organizations tab
     And I click on an organization
    Then I should see the organization details
  
  Scenario: Create an organization, check for folder
   Given a few jurisdictions
     And a few roles
     And a few users with various roles
    When I navigate to the manage organizations tab
     And I press "New Organization"
     And I fill in the organization form
     And I give the organization an audience
     And I press "Save"
    Then I should have a new organization
     And my organization should have some recipients
     And my organization should have a folder
    When I click on an organization
    Then I should see the organization details
     
  Scenario: Test validations
   Given the following entities exist:
      | organization | TALHO |
    When I navigate to the manage organizations tab
     And I press "New Organization"
     And I press "Save"
    Then the required organization fields should be invalid
    When I fill in the organization form
     And I fill in "Name" with "TALHO"
     And I press "Save"
     And I wait for the "Saving..." mask to go away
    Then the "Name" field should be invalid
  
  Scenario: Edit an organization, check for folder
   Given a few jurisdictions
     And a few roles
     And a few users with various roles
     And a few organizations
    When I navigate to the manage organizations tab
     And I edit an organization
     And I fill in the organization form
     And I give the organization an audience
     And I press "Save"
    Then my organization should be updated
     And my organization should have some recipients
     And my organization should have a folder
    
  Scenario: Delete organization
   Given a few organizations
    When I navigate to the manage organizations tab
    When I delete an organization
    Then my organization shouldn't exist