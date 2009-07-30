Feature: Editing user profiles
In order to update contact information
as a user
I should be able to edit my profile

  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Public | Potter County |

  Scenario: editing user information
    Given I am logged in as "john.smith@example.com"
    When I go to the edit profile page
    Then I should see the profile edit form
    
    When I fill in the form with the following info:
      | Description                       | A developer |
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
    And I attach the file at "spec/fixtures/keith.jpg" to "Photo"
    And I press "Save"
    Then I should see the profile page
    And I should not see any errors
    And I should see "Profile information saved"
    
  Scenario: editing user account information
    Given I am logged in as "john.smith@example.com"
    When I go to the user edit page 
    Then I should be redirected to the edit profile page


  Scenario: editing user account information for another user as a non-admin
    Given I am logged in as "jane.smith@example.com"
    When I edit the profile for john.smith@example.com
    Then I should see "You are not authorized to edit this profile."
