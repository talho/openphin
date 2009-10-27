Feature: Viewing groups
  In order to send alerts to a pre-defined list of users
  as an alerter
  I should be able to view, edit and delete user groups

  Background:
    Given the following entities exists:
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
      | Role         | Epidemiologist |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the role "Admin" is an alerter
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public         | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer | Potter County |
      | Health Officer2 | ho1@example.com          | Health Officer | Dallas County |
      | Health Officer1 | ho2@example.com          | Health Officer | Dallas County |
      | Jill Smith      | jill.smith@example.com   | Admin          | Potter County |
      | Jim Smith       | jim.smith@example.com    | Admin          | Dallas County |
      | Will Smith      | will.smith@example.com   | Admin          | Potter County |
    And the following groups for "jill.smith@example.com" exist:
      | Dallas County Health Officer Group              | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Dallas County Health Officer Jurisdiction Group | Dallas County | Health Officer | john.smith@example.com | Jurisdiction | Potter County |
    Given I am logged in as "jill.smith@example.com"

    Scenario: going to view a user group as an admin
      When I go to the dashboard page
      Then I should see "Manage Groups"
      When I follow "Manage Groups"
      Then I should see "Dallas County Health Officer Group"
      And I follow "Dallas County Health Officer Group"
      Then I have loaded the group page for "Dallas County Health Officer Group"
      And I should see that the group includes:
        | Health Officer1, Health Officer2 |

  Scenario: going to view a user group as an admin 
    When I go to the dashboard page
    Then I should see "Manage Groups"
    When I follow "Manage Groups"
    Then I should see "Dallas County Health Officer Group"
    And I follow "Dallas County Health Officer Group"
    Then I should see the user "Health Officer1" immediately before "Health Officer2"


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
      | group_jurisdictions | Dallas County,Potter County    |

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
      | group_roles | Health Officer,Epidemiologist           |

  Scenario: updating a user group with individual users
    When I load the edit group page for "Dallas County Health Officer Group"
    Then I should see "People"
    When I fill out the group form with:
      | Name  | User list Group |
      | Users | Jane Smith      |
    Then I press "Save"
    Then I should see the following group summary:
      | name  | User list Group       |
      | group_users | Jane Smith            |
    And I follow "Jane Smith"
    Then I should see the profile page for "jane.smith@example.com"

  Scenario: deleting a user group
    When I go to the groups page
    Then I should see "Dallas County Health Officer Group"
    When I follow "Destroy"
    Then I should see "Successfully deleted the group Dallas County Health Officer Group."
    When I go to the groups page
    Then I should not see "Dallas County Health Officer Group"

  Scenario: updating changed scope
    When I load the edit group page for "Dallas County Health Officer Group"
    Then I should see "Scope"
    When I fill out the group form with:
      | Scope  | Global |
    Then I press "Save"
    Then I should see the following group summary:
      | name  | Dallas County Health Officer Group       |
      | group_scope | Global                                   |

  Scenario: selecting the jurisdiction when scope is jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Wise County"
    When I load the edit group page for "Dallas County Health Officer Group"
    Then I should see "Scope"
    When I fill out the group form with:
      | Scope              | Jurisdiction |
      | Owner Jurisdiction | Wise County  |
    Then I press "Save"
    Then I should see the following group summary:
      | name               | Dallas County Health Officer Group  |
      | group_scope              | Jurisdiction                        |
      | owner_jurisdiction | Wise County                         |

  Scenario: updating a jurisdiction scoped group to another jurisdiction should be viewable by alerters in the new jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Dallas County"
    When I load the edit group page for "Dallas County Health Officer Jurisdiction Group"
    Then I should see "Scope"
    When I fill out the group form with:
      | Scope              | Jurisdiction   |
      | Owner Jurisdiction | Dallas County  |
    Then I press "Save"
    Then I should see the following group summary:
      | name               | Dallas County Health Officer Jurisdiction Group  |
      | group_scope              | Jurisdiction                                     |
      | owner_jurisdiction | Dallas County                                    |
    Given I am logged in as "jim.smith@example.com"
    When I go to the groups page
    Then I should see "Dallas County Health Officer Jurisdiction Group"

  Scenario: updating a jurisdiction scoped group to another jurisdiction should not be viewable by alerters in the old jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Dallas County"
    When I load the edit group page for "Dallas County Health Officer Jurisdiction Group"
    Then I should see "Scope"
    When I fill out the group form with:
      | Scope              | Jurisdiction   |
      | Owner Jurisdiction | Dallas County  |
    Then I press "Save"
    Then I should see the following group summary:
      | name               | Dallas County Health Officer Jurisdiction Group  |
      | group_scope              | Jurisdiction                                     |
      | owner_jurisdiction | Dallas County                                    |
    Given I am logged in as "will.smith@example.com"
    When I go to the groups page
    Then I should not see "Dallas County Health Officer Jurisdiction Group"
