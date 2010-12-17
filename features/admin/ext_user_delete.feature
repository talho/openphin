Feature: An admin deleting users
  In order to keep users happy
  As an admin
  I can delete users

  Background:
    Given an organization named Red Cross
    And the following entities exist:
      | Jurisdiction | Texas            |
      | Jurisdiction | Dallas County    |
      | Role         | Medical Director |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | Jane Smith | jane.smith@example.com | Public | Dallas County |
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com      |
    And a role named Public
    And an approval role named Health Alert and Communications Coordinator
    And I am logged in as "bob.jones@example.com"
    And delayed jobs are processed

  Scenario: Delete a user
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And all email has been delivered

    When I am logged in as "bob.jones@example.com"
    And I go to the ext dashboard page
    And I navigate to "Admin > Manage Users > Edit Users"
    And I click x-grid3-row "Jane Smith"
    And I press "Delete User"
    And I press "Yes"
    And delayed jobs are processed
    Then I should not see "Jane Smith"
    And "jane.smith@example.com" should not exist

  Scenario: Sending alerts with only People in the audience should work
    Given the following entities exist:
      | Jurisdiction | Texas         |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Texas |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    Then the "Send Alert" tab should be open
    When I fill in the following:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | This is a test message to pass validation    |
    And I check "E-mail"
    And I select "Texas" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    Then I should have the "Audience" breadcrumb selected
    And I select the following in the audience panel:
      | name        | type |
      | Jane Smith  | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected
    And I press "Send"
    And delayed jobs are processed
    And "jane.smith@example.com" is deleted as a user by "john.smith@example.com"
    And delayed jobs are processed
    Then an alert should not exist with:
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |

  Scenario: Not permit multiple case insensitive email users unless the first user has been deleted
    Given I signup for an account with the following info:
      | Email          | greg.brown@example.com |
      | Password       | Apples1          |
      | Password Confirmation | Apples1   |
      | First Name     | Greg             |
      | Last Name      | Brown            |
      | Home Jurisdiction  | Dallas County    |
    Then I should see "Thanks for signing up"
    And "greg.brown@example.com" should have the "Public" role for "Dallas County"

    When I signup for an account with the following info:
      | Email          | Greg.Brown@example.com |
      | Password       | Apples1          |
      | Password Confirmation | Apples1   |
      | First Name     | Greg             |
      | Last Name      | Brown            |
      | Home Jurisdiction  | Dallas County    |
    Then I should not see "Thanks for signing up"

    When delayed jobs are processed
    And I go to the ext dashboard page
    And I navigate to "Admin > Manage Users > Edit Users"
    And I click x-grid3-row "Greg Brown"
    And I press "Delete User"
    And I press "Yes"
    Then I should not see "Greg Brown"

    # delayed jobs must be repeated below for the delete above to be picked up
    And delayed jobs are processed
    When I signup for an account with the following info:
      | Email          | greg.brown@example.com |
      | Password       | Apples1          |
      | Password Confirmation | Apples1   |
      | First Name     | Greg             |
      | Last Name      | Brown            |
      | Home Jurisdiction  | Dallas County    |
    Then I should see "Thanks for signing up"
