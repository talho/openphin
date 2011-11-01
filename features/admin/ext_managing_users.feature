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
    And the role "Health Alert and Communications Coordinator" is for the "phin" application
    And I reindex sphinx
  
  Scenario: Creating a user
    Given I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    When I fill in the add user form with:
      | Email address     | john.smith@example.com |
      | First name        | John                   |
      | Last name         | Smith                  |
      | Password          | Password1              |
      | Confirm password  | Password1              |
      | Display name      | Jonathan Smith         |
      | Language          | English                |
      | Home Jurisdiction | Dallas County          |
    And I request the role "Health Alert and Communications Coordinator" for "Dallas County" in the RolesControl
    And I request the org "Red Cross" in the OrgsControl
    And I press "Apply Changes"
    And delayed jobs are processed
    Then I should see "The user has been successfully created"
    And "john.smith@example.com" should have the "Public" role for "Dallas County"
    And "john.smith@example.com" should have the "Health Alert and Communications Coordinator" role for "Dallas County"
    And "john.smith@example.com" should receive the email:
      | body contains | You have been made a member of the organization Red Cross. |
    And "john.smith@example.com" should not receive an email with the subject "Request submitted for Health Officer in Dallas County"
    And the following users should not receive any emails
      | roles         | Dallas County / Admin |
  
  Scenario: Editing a user's profile
    Given I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    And I edit the user profile for "Jonas Brothers"
    And I fill in the ext form with the following info:
      | Job description                   | A developer |
      | Display name                      | Keith G. |
      | Language                          | English |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |
    And I attach the file "spec/fixtures/keith.jpg" to "user[photo]"
    And I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"
    
  Scenario: Editing a user's profile as an administrator of an parent jurisdiction
    Given I am logged in as "joe.smith@example.com"
    When I navigate to the ext dashboard page
    And I edit the user profile for "Jonas Brothers"
    When I fill in the ext form with the following info:
      | Job description                   | A developer |
      | Display name                      | Keith G. |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |
    And I attach the file "spec/fixtures/keith.jpg" to "user[photo]"
    And I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"

  Scenario: Editing a user's profile and deleting roles
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And I reindex sphinx
    And I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    And I edit the user profile for "Jane Smith"
    Then "jane.smith@example.com" should have the "Health Officer" role in "Dallas County"
    And I should see "Health Officer in Dallas County"
    When I remove the role "Health Officer" for "Dallas County" from EditProfile
    Then "jane.smith@example.com" should not have the "Health Officer" role in "Dallas County"
    And I should not see "Health Officer in Dallas County" within ".role-item"
    And I should see "Profile information saved."

  Scenario: Add user as admin should not occur if no home jurisdictation is specified
    Given I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    When I fill in the add user form with:
      | Email address  | john.smith@example.com |
      | First name     | John                   |
      | Last name      | Smith                  |
      | Password       | Password1              |
      | Confirm password | Password1            |
      | Display name   | Jonathan Smith         |
      | Language       | English                |
    And I request the role "Health Alert and Communications Coordinator" for "Dallas County" in the RolesControl
    And I request the org "Red Cross" in the OrgsControl
    And I press "Apply Changes"
    And delayed jobs are processed
    Then "john@example.com" should not receive an email
    And "john@example.com" should not exist
	  And "bob.jones@example.com" should not receive an email
    
  Scenario: Editing a user's profile by adding user and organizational contact info
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And I reindex sphinx
    And I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    And I edit the user profile for "Jane Smith"
    Then "jane.smith@example.com" should have the "Health Officer" role in "Dallas County"
    When I fill in "Office phone" with "888-123-1212"
    And I fill in "Office fax" with "888-456-1212"
    And I fill in "Home phone" with "888-555-1212"
    And I fill in "Mobile phone" with "888-432-1212"
    And I press "Apply Changes"
    Then I should see "Profile information saved"

  Scenario: Not permitting a second user to be created with the same case-folded e-mail
    Given I am logged in as "bob.jones@example.com"
    When I navigate to the ext dashboard page
    When I fill in the add user form with:
      | Email address  | jane.smith@example.com |
      | First name     | Jane                   |
      | Last name      | Smith                  |
      | Password       | Password1              |
      | Confirm password | Password1            |
      | Language       | English                |
      | Home Jurisdiction | Dallas County       |
    And I request the role "Health Alert and Communications Coordinator" for "Dallas County" in the RolesControl
    And I request the org "Red Cross" in the OrgsControl
    And I press "Apply Changes"
    And delayed jobs are processed
    Then I should see "Email address is already being used on another user account"
