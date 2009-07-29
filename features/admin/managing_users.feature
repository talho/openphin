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
    And jonas.brothers@example.com has a public profile
    And an approval role named Health Alert and Communications Coordinator
    And I am logged in as "bob.jones@example.com"
  
  Scenario: Creating a user
    When I create a user account with the following info:
      | Email          | john.smith@example.com |
      | Password       | password         |
      | Password confirmation | password  |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Are you with any of these organizations | Red Cross        |
      | What County    | Dallas County    |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
    Then "john.smith@example.com" should have the "Public" role for "Dallas County"
    And "john.smith@example.com" should have the "Health Alert and Communications Coordinator" role for "Dallas County"
    
    And "john.smith@example.com" should not receive an email with the subject "Request submitted for Health Officer in Dallas County"

    And the following users should not receive any emails
      | roles         | Dallas County / Admin |
    
    When I log in as "john.smith@example.com"
    Then I should not see "Awaiting Approval"
   
  Scenario: Creating a user with invalid data
    When I create a user account with the following info:
      | Email          | invalidemail    |
      | Password       | password        |
      | Password confirmation | <blank>  |
    Then I should see error messages
    
  Scenario: Editing a user's profile
    When I view the profile page for jonas.brothers@example.com
    And I follow "Edit"
    Then I should see the profile edit form

    When I fill in the form with the following info:
      | First name                        | Keith  |
      | Last name                         | Gaddis |
      | Description                       | A developer |
      | Preferred name to be displayed    | Keith G. |
      | Email                             | kbg@example.com |
      | Preferred language                | English |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |
    And I attach the file at "spec/fixtures/keith.jpg" to "Photo"
    And I press "Save"
    Then I should see the profile page
    And I should not see any errors
    And I should see "Profile information saved"