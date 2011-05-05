@ext
Feature: Sort-Of-RBAC.  Role and user visibility determined by role application

  In order to keep the hot side hot and the cool side cool
  As an admin
  I should not see users or roles for applications I do not have installed

  Background:
    Given the following entities exist:
      | Role         | School Nurse | rollcall |
      | Role         | Hamlet       | stage    |
      | Role         | Average Guy  | phin     |
      | Jurisdiction | Texas        |          |
    And the following users exist:
      | Sys Admin        | sysadmin@example.com        | SysAdmin     | Texas |
      | Phin Admin       | phinadmin@example.com       | Admin        | Texas |
      | Phin SuperAdmin  | phinsuperadmin@example.com  | SuperAdmin   | Texas |
      | Phin User        | phinuser@example.com        | Average Guy  | Texas |
      | Rollcall Nurse   | rollcallnurse@example.com   | School Nurse | Texas |
      | Patrick Stewart  | numberone@example.com       | Hamlet       | Texas |

  Scenario: Phin User in role request dialog should see only non-admin phin roles
    Given I am logged in as "phinuser@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Phin User > Manage Roles"
    And I press "Request Role"
    When I open ext combo "Role"
    Then I should see "Public" within ".x-combo-list"
    And I should see "Average Guy" within ".x-combo-list"
    And I should not see "School Nurse" within ".x-combo-list"
    And I should not see "Hamlet" within ".x-combo-list"

  Scenario: Phin SuperAdmin in role request dialog should see only phin roles
    Given I am logged in as "phinsuperadmin@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Phin SuperAdmin > Manage Roles"
    And I press "Request Role"
    When I open ext combo "Role"
    Then I should see "Public" within ".x-combo-list"
    And I should see "SuperAdmin" within ".x-combo-list"
    And I should see "Average Guy" within ".x-combo-list"
    And I should not see "School Nurse" within ".x-combo-list"
    And I should not see "Hamlet" within ".x-combo-list"

  Scenario: SysAdmin in role request dialog should see all roles
    Given I am logged in as "sysadmin@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Sys Admin > Manage Roles"
    And I press "Request Role"
    When I open ext combo "Role"
    Then I should see "Public" within ".x-combo-list"
    And I should see "SuperAdmin" within ".x-combo-list"
    And I should see "Average Guy" within ".x-combo-list"
    And I should see "School Nurse" within ".x-combo-list"
    And I should see "Hamlet" within ".x-combo-list"

  Scenario: Phin Superadmin in audit log cannot see actions taken by users with rollcall role
    Given I am logged in as "rollcallnurse@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Rollcall Nurse > Edit My Account"
    And I fill in "2134567890" for "Office phone"
    And I press "Apply Changes"
    And I wait for the "Loading..." mask to go away
    Then I should see "Profile information saved."
    And I am logged in as "phinuser@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Phin User > Edit My Account"
    And I fill in "2134567890" for "Office phone"
    And I press "Apply Changes"
    And I wait for the "Loading..." mask to go away
    Then I should see "Profile information saved."
    When I am logged in as "phinsuperadmin@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then I should see "Phin User" within ".x-grid3-cell-inner"
    And I should not see "Rollcall Nurse" within ".x-grid3-cell-inner"

  Scenario: SysAdmin in audit log can see all actions.
    Given I am logged in as "rollcallnurse@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Rollcall Nurse > Edit My Account"
    And I fill in "2134567890" for "Office phone"
    And I press "Apply Changes"
    And I wait for the "Loading..." mask to go away
    Then I should see "Profile information saved."
    And I am logged in as "phinuser@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Phin User > Edit My Account"
    And I fill in "2134567890" for "Office phone"
    And I press "Apply Changes"
    And I wait for the "Loading..." mask to go away
    Then I should see "Profile information saved."
    When I am logged in as "sysadmin@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then I should see "Phin User" within ".x-grid3-cell-inner"
    And I should see "Rollcall Nurse" within ".x-grid3-cell-inner"