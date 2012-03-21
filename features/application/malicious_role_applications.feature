Feature: Preventing malicious attempts to gain access to role applications

  In order to prevent users from accessing unauthorized applications
  As an admin
  Roles should not be approved without application harmony

  Background:
    Given the following entities exist:
      | Role         | School Nurse | rollcall |
      | Role         | Hamlet       | stage    |
      | Role         | Average Guy  | phin     |
      | Jurisdiction | Texas        |          |
    And the following users exist:
      | Sys Admin        | sysadmin@example.com        | SysAdmin     | Texas |          |
      | Phin Admin       | phinadmin@example.com       | Admin        | Texas |          |
      | Phin SuperAdmin  | phinsuperadmin@example.com  | SuperAdmin   | Texas |          |
      | Phin User        | phinuser@example.com        | Average Guy  | Texas | phin     |
      | Rollcall Nurse   | rollcallnurse@example.com   | School Nurse | Texas | rollcall |
      | Patrick Stewart  | numberone@example.com       | Hamlet       | Texas | stage    |

  Scenario: Phin User cannot maliciously request an alien application role
    Given I am logged in as "phinuser@example.com"
    And I maliciously request the role "School Nurse" in "Texas"
    And I wait for 1 second
    Then I should have no pending role requests
   
  Scenario: Phin Admin cannot maliciously request an alien application role
    Given I am logged in as "phinadmin@example.com"
    And I maliciously request the role "School Nurse" in "Texas"
    And I wait for 1 second
    Then I should have no pending role requests

  Scenario: Phin SuperAdmin cannot maliciously request an alien application role
    Given I am logged in as "phinsuperadmin@example.com"
    And I maliciously request the role "School Nurse" in "Texas"
    And I wait for 1 second
    Then I should have no pending role requests

  Scenario: SysAdmin CAN maliciously request an alien application role
    Given I am logged in as "sysadmin@example.com"
    And I maliciously request the role "School Nurse" in "Texas"
    And I wait for 1 second
    Then "sysadmin@example.com" should have the role "School Nurse" in "Texas"

  Scenario: Phin SuperAdmin cannot maliciously fetch version data for actions by a user with an alien role
    Given I am logged in as "numberone@example.com"
    And I navigate to "Patrick Stewart>Edit My Account"
    And I fill in "Display name" with "Jean Luc Picard"
    And I press "Apply Changes"
    And I wait for the "Saving..." mask to go away
    And I fill in "Display name" with "John Luke Pickerd"
    And I press "Apply Changes"
    And I wait for the "Saving..." mask to go away
    And I sign out
    And I should see "Sign In to Your Account"

    When I am logged in as "phinsuperadmin@example.com"
    And I visit the url for the last audit action by "numberone@example.com"
    Then I should see "You do not have permission"
    And I sign out
    And I should see "Sign In to Your Account"

    When I am logged in as "sysadmin@example.com"
    And I visit the url for the last audit action by "numberone@example.com"
    Then I should not see "You do not have permission"


