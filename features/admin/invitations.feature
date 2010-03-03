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
    And "jane.smith@example.com" is an invitee of "DSHS"
    And "joe.smith@example.com" is not an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email                  | message                                   |
      | jane.smith@example.com | Please click the link below to join DSHS. |

  Scenario: Create and Send an invite via a CSV file with invitees
    When I follow "Admin"
    And I follow "Invite Users"
    And I should see "Invite New People"
    And I fill in "Name" with "DSHS"
    And I fill in "Subject" with "Please Join DSHS"
    And I fill in "Body" with "Please click the link below to join DSHS."
    And I select "DSHS" from "Default Organization"
    When I attach the file at "spec/fixtures/invitees.csv" to "CSV File"
    When I press "Submit"
    Then I should see "Invitation was successfully sent."
    And "bob@example.com" is an invitee of "DSHS"
    And "john@example.com" is an invitee of "DSHS"
    And "joe.smith@example.com" is not an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email            | message                                   |
      | bob@example.com  | Please click the link below to join DSHS. |
      | john@example.com | Please click the link below to join DSHS. |

