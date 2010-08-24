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
    And the sphinx daemon is running
    And delayed jobs are processed
  
  Scenario: Attempt to delete an invalid user
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    When I go to the users delete page for an admin
    And I fill in fcbk control with "Zzzjonah"
    And I press "Delete Users"
    Then I should see "A valid user was not selected"
    
  Scenario: Delete a user
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And all email has been delivered

    And I am logged in as "bob.jones@example.com"
    And I go to the roles requests page for an admin
    And I show dropdown menus
    And I follow "Assign Role"
    When I fill out the assign roles form with:
      | People       | Jane Smith     |
      | Jurisdiction | Dallas County  |
      | Role         | Medical Director |
      
    Then "jane.smith@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Medical Director in Dallas County |
    And I should see "jane.smith@example.com has been approved for the role Medical Director in Dallas County"

    When I go to the users delete page for an admin
    And I fill out the delete user form with "Jane Smith"
    And I press "Delete Users"
    
    Then I should see "Users have been successfully deleted"

    When I go to the users delete page for an admin
    And I fill out the delete user form with "Jane Smith"
    
    Then I should not see "Jane Smith"
    
    Then "jane.smith@example.com" should not exist

  Scenario: Sending alerts with only People in the audience should work
    Given the following entities exist:
      | Jurisdiction | Texas         |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator  | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert "Details" form with:
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
    And I check "E-mail"
    And I press "Select an Audience"
    And I fill out the alert "Audience" form with:
      | People   | Jane Smith                              |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | People   | Jane Smith |
      
    And I press "Send"
    And "jane.smith@example.com" is deleted as a user by "john.smith@example.com"
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
    
    When I go to the users delete page for an admin
    And I fill out the delete user form with "Greg Brown"
    And I press "Delete Users"
    Then I should see "Users have been successfully deleted"

    When I signup for an account with the following info:
      | Email          | greg.brown@example.com |
      | Password       | Apples1          |
      | Password confirmation | Apples1   |
      | First name     | Greg             |
      | Last name      | Brown            |
      | Home Jurisdiction  | Dallas County    |
    Then I should see "Thanks for signing up"
 
