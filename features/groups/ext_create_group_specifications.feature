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
    When delayed jobs are processed

  Scenario: going to add a user group as an admin
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    When I press "Create New Group"
    Then the "Create New Group" tab should be open
    And the "Manage Groups" tab should not be open
    And I should see the ext add group form

  Scenario: going to add a user group as a non-admin user
    Given I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    Then I should not see "Admin"
    When I force open the tab "Manage Groups" for "/admin_groups"
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Manage Groups" tab should not be open
    When I close the active ext window
    And I force open the tab "Create New Group" for "/admin_groups/new"
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Create New Group" tab should not be open

  Scenario: going to add a user group as a public user
    Given I am logged in as "jane.smith@example.com"
    When I go to the ext dashboard page
    Then I should not see "Admin"
    When I force open the tab "Manage Groups" for "/admin_groups"
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Manage Groups" tab should not be open
    When I close the active ext window
    And I force open the tab "Create New Group" for "/admin_groups/new"
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Create New Group" tab should not be open

  Scenario: adding a user group with jurisdictions
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I fill in the following:
      | Group Name         | Dallas County Group |
      | Scope              | Personal            |
      | Owner Jurisdiction | Potter County       |
    And I select the following in the audience panel:
      | name          | type         |
      | Dallas County | Jurisdiction |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Group |
      | group_owner_jurisdiction | Potter County       |
      | group_scope              | Personal            |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | John Smith      | Recipient    |
      | Jim Smith       | Recipient    |

  Scenario: adding a user group with roles
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Health Officer Group |
      | Scope              | Personal             |
      | Owner Jurisdiction | Potter County        |
      And I select the following in the audience panel:
      | name           | type |
      | Health Officer | Role |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Health Officer Group |
      | group_owner_jurisdiction | Potter County        |
      | group_scope              | Personal             |
    And I should see the following audience breakdown
      | name            | type      |
      | Health Officer  | Role      |
      | Jane Smith      | Recipient |

  Scenario: adding a user group with jurisdictions and roles
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Personal                           |
      | Owner Jurisdiction | Potter County                      |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Potter County                      |
      | group_scope              | Personal                           |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |

  Scenario: adding a user group with individual users
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    When I click x-accordion-hd "Users"
    And I fill in the following:
      | Group Name         | User list Group |
      | Scope              | Personal        |
      | Owner Jurisdiction | Potter County   |
    And I fill in "User" with "Jane Smith"
    #we need to wait for the search to complete and select an item in order to fire off the result
    And I click x-combo-list-item "Jane Smith - jane.smith@example.com"
    Then I press "Save"
    Then I should see the following group summary:
      | group_name               | User list Group |
      | group_owner_jurisdiction | Potter County   |
      | group_scope              | Personal        |
    And I should see the following audience breakdown
      | name       | type      |
      | Jane Smith | Recipient |
      | Jane Smith | User      |
    And I click inlineLink "Jane Smith"
    Then I should see the profile tab for "jane.smith@example.com"

  Scenario: selecting the jurisdiction when scope is jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Wise County"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Jurisdiction                       |
      | Owner Jurisdiction | Wise County                        |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    Then I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Wise County                        |
      | group_scope              | Jurisdiction                       |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |

  Scenario: adding a personal scoped group should not be viewable by others
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    And I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Personal                           |
      | Owner Jurisdiction | Potter County                      |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Potter County                      |
      | group_scope              | Personal                           |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |
    #get around sign-in page redirection
    Given I am on the ext dashboard page
    And I am logged in as "will.smith@example.com"
    When I go to the ext dashboard page
    When I navigate to "Admin > Manage Groups"
    Then I should not see "Dallas County Health Officer Group"

  Scenario: adding a jurisdiction scoped group should be viewable by other alerters in the same jurisdiction
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    And I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Jurisdiction                       |
      | Owner Jurisdiction | Potter County                      |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Potter County                      |
      | group_scope              | Jurisdiction                       |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |
    Given I am on the ext dashboard page
    And I am logged in as "will.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then I should see "Dallas County Health Officer Group"

  Scenario: adding a jurisdiction scoped group should not be viewable by other alerts in other jurisdictions
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Jurisdiction                       |
      | Owner Jurisdiction | Potter County                      |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Potter County                      |
      | group_scope              | Jurisdiction                       |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |
    Given I am on the ext dashboard page
    And I am logged in as "jim.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then I should not see "Dallas County Health Officer Group"

  Scenario: adding a global scoped group should be viewable by alerters in the same or other jurisdictions
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Dallas County Health Officer Group |
      | Scope              | Global                             |
      | Owner Jurisdiction | Potter County                      |
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
      | group_owner_jurisdiction | Potter County                      |
      | group_scope              | Global                             |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Health Officer  | Role         |
    Given I am on the ext dashboard page
    And I am logged in as "jim.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then I should see "Dallas County Health Officer Group"

  Scenario: adding a scoped group without all data to see error
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    And I press "Create New Group"
    Then I should see the ext add group form
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I fill in the following:
      | Group Name    | Dallas County Group |
    And I press "Save"
    Then I should not see "Dallas County Group"
    And I should see "You must select at least one role, one jurisdiction, or one user."