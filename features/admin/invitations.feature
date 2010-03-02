Feature: Invitation System
  In order to get people to register in the system
  As an administrator
  I should be able to use the invitation system to invite people by email to sign up
  And I should to be see reports on people's sign up progress

  Background: 
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Organization | DSHS          |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com      |
    And I am logged in as "joe.smith@example.com"
    And I am on the dashboard page
    
  Scenario: Create and Send an invite
    When I follow "Admin"
    And I follow "Invite Users"
    And I should see "Invite New People"
    And I fill in "Name" with "DSHS"
    And I fill in "Subject" with "Please Join DSHS"
    And I fill in "Body" with "Please click the link below to join DSHS."
    And I select "DSHS" from "Default Organization"
    And I fill in "Invitee Name" with "Jane Smith"
    And I fill in "Invitee Email" with "jane.smith@example.com"
    When I press "Submit"
    Then I should see "Invitation was successfully sent."
