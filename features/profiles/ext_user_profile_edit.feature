Feature: Editing user profiles
In order to update contact information
as a user
I should be able to edit my profile

  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Texas          |
      | Role         | Health Officer |
      | System role  | SuperAdmin     |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Public | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
      | Bob Smith       | bob.smith@example.com    | SuperAdmin  | Texas    |
    When delayed jobs are processed

  Scenario: editing user information
    Given I am logged in as "john.smith@example.com"
    And I navigate to "John Smith > Edit My Account"
    And I fill in the ext form with the following info:
      | Job description                   | A developer |
      | Display name                      | Keith G. |
      | Language                          | English |
      | Job title                         | Developer |
      | Employer                          | State of Texas |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
    And I attach the file "spec/fixtures/keith.jpg" to "Picture to upload"
    And I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"
    
  Scenario: editing user account information for another user as a non-admin
    Given I am logged in as "jane.smith@example.com"
     When I wait for the "Loading PHIN..." mask to go away
      And I view the ext profile page for "john.smith@example.com"
     Then I should not see "Edit This Account"
    
  Scenario: editing user account information for another user as another jurisdictional admin
    Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Admin" in "Potter County"
    And I am logged in as "jane.smith@example.com"
     When I wait for the "Loading PHIN..." mask to go away
    And I view the ext profile page for "john.smith@example.com"
    And I should not see "Edit This Account"

  Scenario: editing user account information with an im device in a profile
    Given I am logged in as "john.smith@example.com"
    And I have an IM device
    And I navigate to "John Smith > Edit My Account"
    Then I should see "Edit My Account"
    And I should see "Last name"
    And I should see "Email"

  Scenario: Editing profile concurrently to an admin editing the user's profile
    Given I am logged in as "john.smith@example.com"
    And I navigate to "John Smith > Edit My Account"
    And I fill in the ext form with the following info:
      | Job description                   | A developer |
      | Display name                      | Keith G. |
      | Language                          | English |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |

    Given session name is "admin session"
    And I am logged in as "bob.smith@example.com"

    And I view the ext profile page for "john.smith@example.com"
    And I press "Edit This Account"

    When I fill in the form with the following info:
      | Display name    | John Smith |
    And I press "Apply Changes"
    And I should see "Profile information saved."

    Given session name is "default"
    And I press "Apply Changes"
    #Then I should see the profile edit form
    And I should see "Another user has recently updated this profile, please try again."
    And I press "Cancel"
    And I navigate to "John Smith > Edit My Account"
    And the "Display name" field should contain "John Smith"
    When I fill in the ext form with the following info:
      | Job description                   | A developer |
      | Display name                      | Keith G. |
      | Language                          | English |
      | Job title                         | Developer |
      | Bio                               | Maybe the austin powers reference was too much |
      | Credentials                       | Rock star, Certified |
      | Experience                        | Summer camp director  |
      | Employer                          | State of Texas |
    And I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"
