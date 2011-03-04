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
      | Briscoe County |
    And the following users exist:
      | Jane Smith | jane.smith@example.com | Public | Dallas County |
      | Zzzz Smith  | zzz.smith@example.com  | Public | Briscoe County |
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
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Users > Edit Users"
    And I click x-grid3-row "Jane Smith"
    And I press "Delete User"
    And I press "Yes"
    And delayed jobs are processed
    Then I should not see "Jane Smith"
    And "jane.smith@example.com" should not exist

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
    And I navigate to the ext dashboard page
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
 
  Scenario: Admin shouldn't be able to delete a user outside of his admin jurisdictions
    When I navigate to the ext dashboard page
    And I maliciously post a destroy user "zzz.smith@example.com"
    And delayed jobs are processed
    # delayed jobs must be repeated for the delete above to be picked up
    And I navigate to the ext dashboard page
    And delayed jobs are processed
    Then "zzz.smith@example.com" should have the "Public" role for "Briscoe County"
