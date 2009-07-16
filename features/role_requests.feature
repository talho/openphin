Feature: Role Requests

  In order to access the appropriate information and alerts
  As a user
  I want to be able to request another role

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Role         | Public                |
      | Role         | Health Officer        |
      | Role         | Immunization Director |
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   | 
  
  Scenario: User requests role
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
    
    When I go to the request a role page
    And I fill out the role request form with:
      | Jurisdiction | Dallas County  |
      | Role         | Health Officer |
    
    Then I should see "Your request to be a Health Officer in Dallas County has been submitted"
    Then I should see I am awaiting approval for Health Officer in Dallas County
    
    And I should see that I have a pending role request
    And "john.smith@example.com" should receive the email:
      | subject       | Request submitted for Health Officer in Dallas County |
      | body contains | Health Officer in Dallas County |

    And the following users should receive the email:
      | roles         | Dallas County / Admin |
      | subject       | User requesting role Health Officer in Dallas County |
      | body contains | requested assignment |
      | body contains | John Smith (john.smith@example.com) |
      | body contains | Health Officer |
      | body contains | Dallas County  |
    
  Scenario: Requesting a role should not display system-roles
    Given there is an system only Admin role
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
    When I go to the request a role page
    Then I should not see "Admin" in the "Role" dropdown
