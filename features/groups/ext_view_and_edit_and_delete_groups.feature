@ext
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
    Given I am logged in as "jill.smith@example.com"
    And the following groups for "jill.smith@example.com" exist:
      | Dallas County Health Officer Group              | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Dallas County Health Officer Jurisdiction Group | Dallas County | Health Officer | john.smith@example.com | Jurisdiction | Potter County |
    When delayed jobs are processed

    Scenario: going to view a user group as an admin
      When I navigate to the ext dashboard page
      And I navigate to "Admin > Manage Groups"
      Then the "Manage Groups" tab should be open
      And I should see "Dallas County Health Officer Group"
      When I click x-grid3-cell "Dallas County Health Officer Group"
      Then the "Group Detail" tab should be open
      And I should see "Dallas County Health Officer Group"
      And I should see the following audience breakdown
        | name            | type      |
        | Health Officer1 | Recipient |
        | Health Officer2 | Recipient |

  # This test does not make sense anymore because the recipient list is client-side sortable now
  #Scenario: going to view a user group ordering as an admin
  #  When I go to the dashboard page
  #  And I follow "Admin"
  #  Then I should see "Manage Groups"
  #  When I follow "Manage Groups"
  #  Then I should see "Dallas County Health Officer Group"
  #  And I follow "Dallas County Health Officer Group"
  #  Then I should see the user "Health Officer1" immediately before "Health Officer2"
  
  Scenario: going to edit a user group as an admin
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    And I should see "Dallas County Health Officer Group"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    Then the "Edit Group" tab should be open
    And the "Group Name" field should contain "Dallas County Health Officer Group"

  Scenario: going to edit a user group as an admin with deleting a user member
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    Then I should see "Dallas County Health Officer Group"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    Then the "Edit Group" tab should be open
    And the "Group Name" field should contain "Dallas County Health Officer Group"
    And I should see "John Smith"
    When I click removeBtn on the "John Smith" grid row within ".selectedItems"
    And I press "Save"
    Then the "Group Detail" tab should be open
    And I should see "Dallas County Health Officer Group"
    And I should not see "John Smith"
    And the "Dallas County Health Officer Group" group should not have the following members:
      | User  | john.smith@example.com |

  Scenario: going to edit a user group as an admin with viewing the user member's profile
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    And I should see "Dallas County Health Officer Group"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    Then the "Edit Group" tab should be open
    And the "Group Name" field should contain "Dallas County Health Officer Group"
    And I should see "John Smith"

  Scenario: going to edit a user group as a non-admin user
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    Then I should see "John Smith"
    Then I should not see "Admin"
    When I force open the manage groups tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Manage Groups" tab should not be open
    When I close the active ext window
    When I force open the group detail tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Group Detail" tab should not be open
    When I close the active ext window
    And I force open the edit group tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Edit Group" tab should not be open

  Scenario: going to edit a user group as a public user
    Given I am logged in as "jane.smith@example.com"
    When I navigate to the ext dashboard page
    Then I should see "Dashboard"
    And I should not see "Admin"
    When I force open the manage groups tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Manage Groups" tab should not be open
    When I close the active ext window
    When I force open the group detail tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Group Detail" tab should not be open
    When I close the active ext window
    And I force open the edit group tab
    Then I should see "That resource does not exist or you do not have access to it."
    And the "Edit Group" tab should not be open

  Scenario: updating a user group with jurisdictions
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I fill in the following:
      | Group Name | Dallas and Potter County Group |
    And I select the following in the audience panel:
      | name          | type         |
      | Potter County | Jurisdiction |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas and Potter County Group |
    And I should see the following audience breakdown
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Potter County   | Jurisdiction |

  Scenario: updating a user group with roles
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    When I click x-accordion-hd "Roles"
    Then I should see the following roles in an ext grid:
      | Health Officer |
      | Epidemiologist |
      | Public         |
    When I fill in the following:
      | Group Name         | Health Officer and Epidemiologist Group |
    And I select the following in the audience panel:
      | name           | type |
      | Epidemiologist | Role |
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Health Officer and Epidemiologist Group |
      | group_owner_jurisdiction | Potter County        |
      | group_scope              | Personal             |
    And I should see the following audience breakdown
      | name            | type |
      | Health Officer  | Role |
      | Epidemiologist  | Role |
    
  Scenario: updating a user group with individual users
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    And I select the following in the audience panel:
      | name       | type | email                  |
      | Jane Smith | User | jane.smith@example.com |
    Then I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group |
    And I should see the following audience breakdown
      | name       | type      |
      | Jane Smith | Recipient |
      | Jane Smith | User      |
    And I click inlineLink "Jane Smith"
    Then I should see the profile tab for "jane.smith@example.com"

  Scenario: deleting a user group
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    And I should see "Dallas County Health Officer Group"
    And  I will confirm on next step
    When I click removeBtn on the "Dallas County Health Officer Group" grid row
    And I wait for the "Loading" mask to go away
    Then I should not see "Dallas County Health Officer Group"
    And the group "Dallas County Health Officer Group" should not exist

  Scenario: updating changed scope
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    And I select "Global" from ext combo "Scope"
    Then I press "Save"
    Then I should see the following group summary:
      | group_name  | Dallas County Health Officer Group       |
      | group_scope | Global                                   |

  Scenario: selecting the jurisdiction when scope is jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Wise County"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Group" grid row
    And I select "Jurisdiction" from ext combo "Scope"
    And I select "Wise County" from ext combo "Owner Jurisdiction"
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Group  |
      | group_scope              | Jurisdiction                        |
      | group_owner_jurisdiction | Wise County                         |

  Scenario: updating a jurisdiction scoped group to another jurisdiction should be viewable by alerters in the new jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Dallas County"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Jurisdiction Group" grid row
    And I select "Jurisdiction" from ext combo "Scope"
    And I select "Dallas County" from ext combo "Owner Jurisdiction"
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Jurisdiction Group  |
      | group_scope              | Jurisdiction                                     |
      | group_owner_jurisdiction | Dallas County                                    |
    Given I am on the ext dashboard page
    And I am logged in as "jim.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then I should see "Dallas County Health Officer Jurisdiction Group"

  Scenario: updating a jurisdiction scoped group to another jurisdiction should not be viewable by alerters in the old jurisdiction
    Given the user "Jill Smith" with the email "jill.smith@example.com" has the role "Admin" in "Dallas County"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Jurisdiction Group" grid row
    And I select "Jurisdiction" from ext combo "Scope"
    And I select "Dallas County" from ext combo "Owner Jurisdiction"
    And I press "Save"
    Then I should see the following group summary:
      | group_name               | Dallas County Health Officer Jurisdiction Group  |
      | group_scope              | Jurisdiction                                     |
      | group_owner_jurisdiction | Dallas County                                    |
    Given I am on the ext dashboard page
    Given I am logged in as "will.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then I should not see "Dallas County Health Officer Jurisdiction Group"

  Scenario: updating a user group currently to another admin updating the same group
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Jurisdiction Group" grid row
    Then I should see the following jurisdictions:
      | Dallas County |
      | Potter County |
    When I fill in the following:
      | Group Name | Dallas and Potter County Jurisdiction Group |
    And I select the following in the audience panel:
      | name          | type         |
      | Potter County | Jurisdiction |

    Given session name is "admin session"
    And I am logged in as "will.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    When I click editBtn on the "Dallas County Health Officer Jurisdiction Group" grid row
    And I select the following in the audience panel:
      | name       | type | email                  |
      | Jane Smith | User | jane.smith@example.com |
    And I press "Save"
    Then I should see the following group summary:
      | group_name | Dallas County Health Officer Jurisdiction Group |
    And I should see the following audience breakdown
      | name          | type         |
      | Dallas County | Jurisdiction |
      | Jane Smith    | User         |
      | John Smith    | User         |

    Given session name is "default"
    And I press "Save"
    Then I should see "The group Dallas County Health Officer Jurisdiction Group has been recently modified by another user. Please try again."
    When I close the active ext window
    And I click editBtn on the "Dallas County Health Officer Jurisdiction Group" grid row
    When I fill in the following:
      | Group Name | Dallas and Potter County Jurisdiction Group |
    And I select the following in the audience panel:
      | name          | type         |
      | Potter County | Jurisdiction |
    And I press "Save"
    Then I should see the following group summary:
      | group_name | Dallas and Potter County Jurisdiction Group |
    And I should see the following audience breakdown
      | name          | type         |
      | Dallas County | Jurisdiction |
      | Potter County | Jurisdiction |
      | Jane Smith    | User         |
      | John Smith    | User         |

  Scenario: Page through groups
    Given the following groups for "jill.smith@example.com" exist:
      | Group A | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group B | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group C | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group F | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group G | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group H | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group I | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group J | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group K | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group L | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group M | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
      | Group N | Dallas County | Health Officer | john.smith@example.com | Personal     | Potter County |
    When I navigate to the ext dashboard page
    And I navigate to "Admin > Manage Groups"
    Then the "Manage Groups" tab should be open
    Then I should see "Dallas County Health Officer Group" in grid row 1
    Then I should see "Dallas County Health Officer Jurisdiction Group" in grid row 2
    Then I should see "Group A" in grid row 3
    Then I should see "Group B" in grid row 4
    Then I should see "Group C" in grid row 5
    Then I should see "Group F" in grid row 6
    Then I should see "Group G" in grid row 7
    Then I should see "Group H" in grid row 8
    Then I should see "Group I" in grid row 9
    Then I should see "Group J" in grid row 10
    When I click x-tbar-page-next ""
    And I wait for the "Loading..." mask to go away
    Then I should see "Group K" in grid row 1
    Then I should see "Group L" in grid row 2
    Then I should see "Group M" in grid row 3
    Then I should see "Group N" in grid row 4
    When I click x-tbar-page-prev ""
    And I wait for the "Loading..." mask to go away
    Then I should see "Dallas County Health Officer Group" in grid row 1
    Then I should see "Dallas County Health Officer Jurisdiction Group" in grid row 2
    Then I should see "Group A" in grid row 3
    Then I should see "Group B" in grid row 4
    Then I should see "Group C" in grid row 5
    Then I should see "Group F" in grid row 6
    Then I should see "Group G" in grid row 7
    Then I should see "Group H" in grid row 8
    Then I should see "Group I" in grid row 9
    Then I should see "Group J" in grid row 10


