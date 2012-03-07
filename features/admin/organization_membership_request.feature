@ext
Feature: Organization Membership Request

  In order to add users to my organization
  As an admin
  I would like to have a place to view, accept, and deny organization membership requests
  
  Background:
   Given a few organizations
     And I am logged in as an admin
     And I am a member of an organization
     And a few users with various roles
  
  Scenario: View organiation request list
   Given a few organization membership requests
    When I navigate to the organization membership request tab
    Then I should see organization membership requests
  
  Scenario: I cannot see requests for organizations I am not a member of
   Given a few organization membership requests for a different organization
    When I navigate to the organization membership request tab
    Then I should not see organization membership requests
  
  Scenario: Approve an organization request
   Given a few organization membership requests
    When I navigate to the organization membership request tab
     And I press "Approve"
    Then my organization should have a new member
   
  Scenario: Deny an organization request
   Given a few organization membership requests
    When I navigate to the organization membership request tab
     And I press "Deny"
    Then my organization should not have a new member
     And the organization request should be deleted