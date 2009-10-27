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

  Scenario: Jurisdiction Admin approving role requests in their jurisdiction via View Pending Requests
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval for "Health Officer"
    And I follow "Pending Role Requests"
    Then I should see "john@example.com" is awaiting approval for "Health Officer"
    When I approve "john@example.com" in the role "Health Officer"
    Then "john@example.com" should receive the email:
      | subject       | Request approved    |
      | body contains | You have been approved for the assignment of Health Officer in Dallas County |
    And I should see "John Smith has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"

  Scenario: Jurisdiction Admin approving role requests in their jurisdiction via han dashboard
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval for "Health Officer"
    When I approve "john@example.com" in the role "Health Officer"
    Then "john@example.com" should receive the email:
      | subject       | Request approved    |
      | body contains | You have been approved for the assignment of Health Officer in Dallas County |
    And I should see "John Smith has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"

  Scenario: Jurisdiction Admin approving role requests outside their jurisdiction via han dashboard
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@potter.gov"
    Then I should not see that "john@example.com" is awaiting approval

  Scenario: Jurisdiction Admin denying role requests in their jurisdiction via han dashboard
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

  Scenario: Malicious admin cannot remove role requests the user is not an admin of
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    And I am logged in as "admin@potter.gov"
    When I maliciously post a deny for a role request for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    And I can't test 'should redirect_to' because of webrat bug
    And I should see "Assign Roles"
    