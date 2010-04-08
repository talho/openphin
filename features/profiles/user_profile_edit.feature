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
      | System role  | Superadmin     |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Public | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
      | Bob Smith       | bob.smith@example.com    | Superadmin  | Texas    |
    When delayed jobs are processed

  Scenario: editing user information
    Given I am logged in as "john.smith@example.com"
    When I go to the edit profile page
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
    When I edit the profile for "john.smith@example.com"
    Then I should see "That resource does not exist or you do not have access to it."
    
  Scenario: editing user account information for another user as another jurisdictional admin
      Given the user "Jane Smith" with the email "jane.smith@example.com" has the role "Admin" in "Potter County"
      And I am logged in as "jane.smith@example.com"
      When I edit the profile for "john.smith@example.com"
      Then I should see "You are not authorized to edit this profile."

  Scenario: editing user account information with an im device in a profile
    Given I am logged in as "john.smith@example.com"
    And I have an IM device
    When I go to the edit profile page
    Then I should see the profile edit form

  Scenario: Adding a user to an organization as a SuperAdmin
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "bob.smith@example.com"
    When I go to the dashboard page
    And I follow "Find People"
    And I fill in "Search" with "Jane"
    And I press "Search"
    Then I see the following users in the search results
      | Jane Smith |
    When I follow "Jane Smith"
    And I follow "Edit this Person"
    Then I should see "Organizations"
    When I select "DSHS" from "organizations"
    And I press "Save"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And the "organizations" class selector should contain "DSHS"

  Scenario: Adding a user to an organization as a user
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I follow "My Account"
    Then I should see "Organizations"
    When I select "DSHS" from "organizations"
    And I press "Save"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And the "organizations" class selector should not contain "DSHS"
    And I should see "Your request to be a member of DSHS has been sent to an administrator for approval"
    And "bob.smith@example.com" should receive the email:
      | subject       | Request submitted for organization membership in DSHS |
      | body contains | DSHS |

    Given I am logged in as "bob.smith@example.com"
    When I click the organization membership request approval link in the email for "jane.smith@example.com"
    And I follow "Approve"
    Then I should see "Jane Smith is now a member of DSHS"

    And I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I follow "My Account"
    Then I should see "Organizations"
    And the "organizations" class selector should contain "DSHS"
    And I press "Save"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And the "organizations" class selector should contain "DSHS"

    Scenario: Adding a user to an organization as a user who maliciously posts an approver id
      Given the following entities exist:
        | Organization | DSHS |
      And I am logged in as "jane.smith@example.com"
      When I go to the dashboard page
      And I follow "My Account"
      Then I should see "Organizations"
      When I select "DSHS" from "organizations"
      And I maliciously post an approver id
      And I press "Save"
      Then I should be specifically on the user profile page for "jane.smith@example.com"
      And I should see "Organizations"
      And the "organizations" class selector should not contain "DSHS"
      And I should see "Your request to be a member of DSHS has been sent to an administrator for approval"
      And "bob.smith@example.com" should receive the email:
        | subject       | Request submitted for organization membership in DSHS |
        | body contains | DSHS |

    Scenario: Removing a user from an organization as an admin
      Given the following entities exist:
        | Organization | DSHS |
      And "jane.smith@example.com" is a member of the organization "DSHS"
      And I am logged in as "bob.smith@example.com"
      When I specifically go to the user edit profile page for "jane.smith@example.com"
      Then I should see "Organizations"
      And I should see "DSHS"
      When I follow "Remove Organization Membership" within ".organizations"
      Then I should be specifically on the user profile page for "jane.smith@example.com"
      And I should see "Organizations"
      And I should not see "DSHS"
      And "jane.smith@example.com" should receive the email:
        | subject       | You have been removed from the organization DSHS |
        | body contains | You have been removed from the organization DSHS |

  Scenario: Removing a user from an organization as that user
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "jane.smith@example.com"
    When I specifically go to the user edit profile page for "jane.smith@example.com"
    Then I should see "Organizations"
    And I should see "DSHS"
    When I follow "Remove Organization Membership" within ".organizations"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And I should not see "DSHS"
    And "jane.smith@example.com" should not receive an email

  Scenario: Removing a user from an organization as another user
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "jill.smith@example.com"
    When I specifically go to the user edit profile page for "jane.smith@example.com"
    Then I should see "Organizations"
    And I should see "DSHS"
    When I maliciously attempt to remove "jane.smith@example.com" from "DSHS"
    Then I should see "You do not have permission to carry out this action."
    And I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And I should see "DSHS"
    And "jane.smith@example.com" should not receive an email
    And "bob.smith@example.com" should not receive an email
