Feature: An admin managing users
  In order to keep users happy
  As an admin
  I can manage user accounts
  
  Background:
    Given an organization named Red Cross
    And the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | Jane Smith | jane.smith@example.com | Public | Dallas County |
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   | 
      | Jonas Brothers | jonas.brothers@example.com |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com      |
    And "jonas.brothers@example.com" is not public in "Texas"
    And a role named Public
    And jonas.brothers@example.com has a public profile
    And an approval role named Health Alert and Communications Coordinator
    And I am logged in as "bob.jones@example.com"
  
  Scenario: Creating a user
    When I create a user account with the following info:
      | Email          | john.smith@example.com |
      | Password       | Password1        |
      | Password confirmation | Password1 |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Are you with any of these organizations | Red Cross        |
      | Home Jurisdiction  | Dallas County    |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
      | Are you a public health professional? | <checked> |
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
      | Password       | Password1       |
      | Password confirmation | <blank>  |
      | Home Jurisdiction | Dallas County |
    Then I should see error messages
    
  Scenario: Editing a user's profile
    When I view the profile page for jonas.brothers@example.com
    And I follow "Edit"
    Then I should see the profile edit form

    When I fill in the form with the following info:
      | Job description                   | A developer |
      | Preferred name to be displayed    | Keith G. |
      | Preferred language                | English |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |
      # | First name                        | Keith  |
      # | Last name                         | Gaddis |
      # | Email                             | kbg@example.com |
    And I attach the file at "spec/fixtures/keith.jpg" to "user_photo"
    And I press "Save"
    Then I should see the profile page
    And I should not see any errors
    And I should see "Profile information saved"
    
    Scenario: Editing a user's profile as an administrator of an parent jurisdiction
      Given I am logged in as "joe.smith@example.com"
      When I view the profile page for jonas.brothers@example.com
      And I follow "Edit"
      Then I should see the profile edit form

      When I fill in the form with the following info:
        | Job description                   | A developer |
        | Preferred name to be displayed    | Keith G. |
        | Preferred language                | English |
        | Job title                         | Developer |
        | Bio                               | Maybe the austin powers reference was too much |
        | Credentials                       | Rock star, Certified |
        | Experience                        | Summer camp director  |
        | Employer                          | State of Texas |
      And I attach the file at "spec/fixtures/keith.jpg" to "user_photo"
      And I press "Save"
      Then I should see the profile page
      And I should not see any errors
      And I should see "Profile information saved"

    Scenario: Editing a user's profile and deleting roles
      Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
      When I view the profile page for jane.smith@example.com
      And I follow "Edit"

      Then "jane.smith@example.com" should have the "Health Officer" role in "Dallas County"
      And I should see the profile edit form
      And I should see "Health Officer in Dallas County"
      When I follow "Remove Role"

      Then "jane.smith@example.com" should not have the "Health Officer" role in "Dallas County"
      And I should see "Role Health Officer removed from Jane Smith in Dallas County"

    Scenario: Add user as admin should not occur if no home jurisdictation is specified
    When I create a user account with the following info:
      | Email          | john@example.com |
      | Password       | Password1        |
      | Password confirmation | Password1 |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction |               |
      | Are you with any of these organizations | Red Cross        |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
      | Are you a public health professional? | <checked> |
    Then "john@example.com" should not receive an email
    And I should not see "Thanks for signing up"
    And "john@example.com" should not exist
	  And "bob.jones@example.com" should not receive an email
    And I should see "Home Jurisdiction needs to be selected"
