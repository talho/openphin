Feature: Approving users for roles
  In order to access alerts
  As a user
  I can request roles

  Background: 
    Given the following entities exists:
      | Organization  | Red Cross      |
      | Jurisdiction  | Dallas County  |
      | Jurisdiction  | Potter County  |
      | approval role | Health Officer |
    And the following administrators exist:
      | admin@dallas.gov | Dallas County |
      | admin@potter.gov | Potter County |
    And the following users exist:
      | John Smith | john@example.com | Public | Texas |

  Scenario: Jurisdiction Admin approving role requests in their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval for "Health Officer"
    When I approve "john@example.com" in the role "Health Officer"
    Then "john@example.com" should receive the email:
      | subject       | Request approved    |
      | body contains | You have been approved for the assignment of Health Officer in Dallas County |
    And I should see "John Smith has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"

  Scenario: Jurisdiction Admin approving role requests outside their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@potter.gov"
    Then I should not see that "john@example.com" is awaiting approval

  Scenario: Jurisdiction Admin denying role requests in their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval for "Health Officer"
    When I deny "john@example.com" in the role "Health Officer"
    Then "john@example.com" should receive the email:
      | subject       | Request denied    |
      | body contains | You have been denied for the assignment of Health Officer in Dallas County |
    And I should see "John Smith has been denied for the role Health Officer in Dallas County"
    And I should not see that "john@example.com" is awaiting approval
    And "john@example.com" should not have the "Health Officer" role in "Dallas County"
