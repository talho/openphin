Feature: Approving users for roles
  In order to access alerts
  As a user
  I can request roles

  Background: 
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And "admin@dallas.gov" is an Admin for "Dallas County"
    And "admin@potter.gov" is an Admin for "Potter County"

  Feature: Jurisdiction Admin approving role requests in their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval
    When I approve "john@example.com"
    Then "john@example.com" should receive an approval notification email
    And I should see "john@example.com" has been approved
    
  Feature: Jurisdiction Admin approving role requests outside their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@potter.gov"
    Then I should not see that "john@example.com" is awaiting approval

  Feature: Jurisdiction Admin denying role requests in their jurisdiction
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    Then I should see "john@example.com" is awaiting approval
    When I deny "john@example.com"
    Then "john@example.com" should receive a denial notification email
    And I should not see that "john@example.com" is awaiting approval
        