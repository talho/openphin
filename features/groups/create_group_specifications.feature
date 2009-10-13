Feature: Creating groups
  In order to send alerts to a pre-defined list of users
  as an alerter
  I should be able to add user groups to my profile

  Background:
    Given the following entities exists:
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
      | Role         | Epidemiologist |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
      | Jim Smith       | jim.smith@example.com    | Admin  | Dallas County |
      | Will Smith      | will.smith@example.com   | Admin  | Potter County |
    Given I am logged in as "jill.smith@example.com"
    And the role "Admin" is an alerter

  Scenario: going to add a user group as an admin
    When I go to the dashboard page
    Then I should see "Manage Groups"
    And I follow "Manage Groups"
    Then I should be on the groups page
    Then I should see "Add Group"
    And I follow "Add Group"
    Then I should be on the add groups page

  Scenario: going to add a user group as a non-admin user
    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    Then I should not see "Manage Groups"
    When I go to the groups page
    Then I should see "That resource does not exist or you do not have access to it."
    And I should be redirected to the dashboard page
    When I go to the add groups page
    Then I should see "That resource does not exist or you do not have access to it."
    And I should be redirected to the dashboard page

  Scenario: going to add a user group as a public user
    Given I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    Then I should not see "Manage Groups"
    When I go to the groups page
    Then I should see "That resource does not exist or you do not have access to it."
    And I should be redirected to the dashboard page
    When I go to the add groups page
    Then I should see "That resource does not exist or you do not have access to it."
    And I should be redirected to the dashboard page

  Scenario: adding a user group with jurisdictions
    When I go to the add groups page
    Then I should see the add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I fill out the group form with:
      | Name          | Dallas County Group |
      | Jurisdictions | Dallas County       |
      | Scope         | Personal            |
    And I press "Save"
    Then I should see the following group summary:
      | name          | Dallas County Group |
      | jurisdictions | Dallas County       |
      | scope         | Personal            |

  Scenario: adding a user group with roles
    When I go to the add groups page
    Then I should see the add group form
    Then I should see the following roles:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill out the group form with:
      | Name  | Health Officer Group |
      | Roles | Health Officer       |
      | Scope | Personal             |
    And I press "Save"
    Then I should see the following group summary:
      | name  | Health Officer Group |
      | roles | Health Officer       |
      | scope | Personal             |

  Scenario: adding a user group with jurisdictions and roles
    When I go to the add groups page
    Then I should see the add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    Then I should see the following roles:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill out the group form with:
      | Name          | Dallas County Health Officer Group |
      | Jurisdictions | Dallas County                      |
      | Roles         | Health Officer                     |
      | Scope         | Personal                           |
    And I press "Save"
    Then I should see the following group summary:
      | name          | Dallas County Health Officer Group |
      | jurisdictions | Dallas County                      |
      | roles         | Health Officer                     |
      | scope         | Personal                           |

  Scenario: adding a user group with individual users
    When I go to the add groups page
    Then I should see the add group form
    Then I should see "People"
    When I fill out the group form with:
      | Name  | User list Group |
      | Users | Jane Smith      |
      | Scope | Personal        |
    Then I press "Save"
    Then I should see the following group summary:
      | name  | User list Group |
      | users | Jane Smith      |
      | scope | Personal        |
    And I follow "Jane Smith"
    Then I should see the profile page for "jane.smith@example.com"

  Scenario: selecting the jurisdiction when scope is jurisdictaion
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Wise County"
    When I go to the add groups page
    Then I should see the add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    Then I should see the following roles:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill out the group form with:
      | Name          | Dallas County Health Officer Group |
      | Jurisdictions | Dallas County                      |
      | Roles         | Health Officer                     |
      | Scope              | Jurisdiction |
      | Owner Jurisdiction | Wise County  |
    Then I press "Save"
    Then I should see the following group summary:
      | name               | Dallas County Health Officer Group  |
      | scope              | Jurisdiction                        |
      | owner_jurisdiction | Wise County                         |

    Scenario: adding a personal scoped group should not be viewable by others
      When I go to the add groups page
      Then I should see the add group form
      Then I should see the following jurisdictions:
        | Dallas County |
        | Potter County |
      Then I should see the following roles:
        | Health Officer |
        | Epidemiologist |
        | Public         |
      When I fill out the group form with:
        | Name          | Dallas County Health Officer Group |
        | Jurisdictions | Dallas County                      |
        | Roles         | Health Officer                     |
        | Scope         | Personal                           |
      Then I press "Save"
      Then I should see the following group summary:
        | name               | Dallas County Health Officer Group |
        | scope              | Personal                           |
      Given I am logged in as "will.smith@example.com"
      When I go to the groups page
      Then I should not see "Dallas County Health Officer Group"

    Scenario: adding a jurisdiction scoped group should be viewable by other alerters in the same jurisdiction
      When I go to the add groups page
      Then I should see the add group form
      Then I should see the following jurisdictions:
        | Dallas County |
        | Potter County |
      Then I should see the following roles:
        | Health Officer |
        | Epidemiologist |
        | Public         |
      When I fill out the group form with:
        | Name               | Dallas County Health Officer Group |
        | Jurisdictions      | Dallas County                      |
        | Roles              | Health Officer                     |
        | Scope              | Jurisdiction                       |
        | Owner Jurisdiction | Potter County                      |
      Then I press "Save"
      Then I should see the following group summary:
        | name               | Dallas County Health Officer Group |
        | scope              | Jurisdiction                       |
      Given I am logged in as "will.smith@example.com"
      When I go to the groups page
      Then I should see "Dallas County Health Officer Group"

    Scenario: adding a jurisdiction scoped group should not be viewable by other alerts in other jurisdictions
      When I go to the add groups page
      Then I should see the add group form
      Then I should see the following jurisdictions:
        | Dallas County |
        | Potter County |
      Then I should see the following roles:
        | Health Officer |
        | Epidemiologist |
        | Public         |
      When I fill out the group form with:
        | Name               | Dallas County Health Officer Group |
        | Jurisdictions      | Dallas County                      |
        | Roles              | Health Officer                     |
        | Scope              | Jurisdiction                       |
        | Owner Jurisdiction | Potter County                      |
      Then I press "Save"
      Then I should see the following group summary:
        | name               | Dallas County Health Officer Group |
        | scope              | Jurisdiction                       |
      Given I am logged in as "jim.smith@example.com"
      When I go to the groups page
      Then I should not see "Dallas County Health Officer Group"

    Scenario: adding a global scoped group should be viewable by alerters in the same or other jursidictions
      When I go to the add groups page
      Then I should see the add group form
      Then I should see the following jurisdictions:
        | Dallas County |
        | Potter County |
      Then I should see the following roles:
        | Health Officer |
        | Epidemiologist |
        | Public         |
      When I fill out the group form with:
        | Name               | Dallas County Health Officer Group |
        | Jurisdictions      | Dallas County                      |
        | Roles              | Health Officer                     |
        | Scope              | Global                             |
      Then I press "Save"
      Then I should see the following group summary:
        | name               | Dallas County Health Officer Group |
        | scope              | Global                             |
      Given I am logged in as "jim.smith@example.com"
      When I go to the groups page
      Then I should see "Dallas County Health Officer Group"
