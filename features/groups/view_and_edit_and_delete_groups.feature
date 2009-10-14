Feature: Viewing groups
In order to send alerts to a pre-defined list of users
as an alerter
I should be able to view, edit and delete user groups

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
      | Role         | Epidemiologist |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
    And the following groups for "jill.smith@example.com" exist:
      | Dallas County Health Officer Group | Dallas County | Health Officer | john.smith@example.com | Personal |
    Given I am logged in as "jill.smith@example.com"

    Scenario: going to view a user group as an admin
      When I go to the dashboard page
      Then I should see "Manage Groups"
      When I follow "Manage Groups"
      Then I should see "Dallas County Health Officer Group"
      And I follow "Dallas County Health Officer Group"
      Then I have loaded the group page for "Dallas County Health Officer Group"

    Scenario: going to edit a user group as an admin
      When I go to the dashboard page
      Then I should see "Manage Groups"
      When I follow "Manage Groups"
      Then I should see "Dallas County Health Officer Group"
      And I follow "Edit"
      Then I have loaded the edit group page for "Dallas County Health Officer Group"

    Scenario: going to edit a user group as a non-admin user
      Given I am logged in as "john.smith@example.com"
      When I go to the dashboard page
      Then I should not see "Add Groups"
      When I go to the add groups page
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page
      When I load the group page for "Dallas County Health Officer Group"
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page
      When I load the edit group page for "Dallas County Health Officer Group"
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page

    Scenario: going to edit a user group as a public user
      Given I am logged in as "jane.smith@example.com"
      When I go to the dashboard page
      Then I should not see "Add Groups"
      When I go to the add groups page
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page
      When I load the group page for "Dallas County Health Officer Group"
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page
      When I load the edit group page for "Dallas County Health Officer Group"
      Then I should see "That resource does not exist or you do not have access to it."
      And I should be redirected to the dashboard page

    Scenario: updating a user group with jurisdictions
      When I load the edit group page for "Dallas County Health Officer Group"
      Then I should see the following jurisdictions:
        | Dallas County |
        | Potter County |
      When I fill out the group form with:
        | Name          | Dallas and Potter County Group |
        | Jurisdictions | Potter County                  |
      And I press "Save"
      Then I should see the following group summary:
        | name          | Dallas and Potter County Group |
        | jurisdictions | Dallas County,Potter County    |

    Scenario: updating a user group with roles
      When I load the edit group page for "Dallas County Health Officer Group"
      Then I should see the following roles:
        | Health Officer |
        | Epidemiologist |
        | Public         |
      When I fill out the group form with:
        | Name  | Health Officer and Epidemiologist Group |
        | Roles | Epidemiologist                          |
      And I press "Save"
      Then I should see the following group summary:
        | name  | Health Officer and Epidemiologist Group |
        | roles | Health Officer,Epidemiologist           |

    Scenario: updating a user group with individual users
      When I load the edit group page for "Dallas County Health Officer Group"
      Then I should see "People"
      When I fill out the group form with:
        | Name  | User list Group |
        | Users | Jane Smith      |
      Then I press "Save"
      Then I should see the following group summary:
        | name  | User list Group       |
        | users | Jane Smith            |
      And I follow "Jane Smith"
      Then I should see the profile page for "jane.smith@example.com"

    Scenario: deleting a user group
      When I go to the groups page
      Then I should see "Dallas County Health Officer Group"
      When I follow "Destroy"
      Then I should see "Successfully deleted the group Dallas County Health Officer Group."
      When I go to the groups page
      Then I should not see "Dallas County Health Officer Group"
