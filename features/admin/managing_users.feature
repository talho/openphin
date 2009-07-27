Feature: An admin managing users
  In order to keep users happy
  As an admin
  I can manage user accounts
  
  Background:
    Given an organization named Red Cross
    And a jurisdiction named Dallas County
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   | 
      | Jonas Brothers | jonas.brothers@example.com |
    And a role named Public
    And an approval role named Health Alert and Communications Coordinator
    And I am logged in as "bob.jones@example.com"
  
  Scenario: Creating a user
    When I create a user account with the following info:
      | Email          | john@example.com |
      | Password       | password         |
      | Password confirmation | password  |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Are you with any of these organizations | Red Cross        |
      | What County    | Dallas County    |
      | What is your primary role within the health department | Health Alert and Communications Coordinator |
      | Preferred language | English      |
    Then "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role for "Dallas County"
    When I log in as "john@example.com"
    Then I should not see "Awaiting Approval"
    