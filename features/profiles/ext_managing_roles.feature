Feature: Removing public roles
In order to keep accurate records and avoid unnecessary alerts
as a user
I should be able to remove all but one public role from my profile

  Background:
    Given the following entities exist:
      | Jurisdiction  | Dallas County            |
      | Jurisdiction  | Potter County            |
      | Jurisdiction  | Texas                    |
      | approval role | BioTerrorism Coordinator |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County  |
    And the following users exist:
      | John Smith    | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"

  Scenario: Adding and removing public roles from user profile
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I press "Add role"
    And I select "Public" from ext combo "rq[role]"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I press "Add"
    Then I should see the following within ".role-item":
      | Potter County | Public | needs to be saved |
    When I press "Save"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Dallas County | Public |
    And I should see the following within ".role-item":
      | Potter County | Public |

  Scenario: Removing all public roles from user profile
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I click role-item "Texas"
    And I press "Remove role"
    Then I should not see "Texas" within ".role-item"
    When I click role-item "Dallas County"
    And I press "Remove role"
    Then I should not see "Dallas County"
    When I press "Save"
    Then I should see "You must have at least one public role"
    And I should see the following within ".role-item":
      | Texas         | Public |
      | Dallas County | Public |

  Scenario: Removing the all public roles from user profile and adding a new public role
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I click role-item "Texas"
    And I press "Remove role"
    And I click role-item "Dallas County"
    And I press "Remove role"
    Then I should see "No roles to display"
    When I press "Add role"
    And I select "Public" from ext combo "rq[role]"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I press "Add"
    And I press "Save"
    Then I should see "Requests sent"
    And I should see the following within ".role-item":
      | Potter County | Public |
    And I should not see "Texas" within ".role-item"
    And I should not see "Dallas County" within ".role-item"

  Scenario: Adding and removing non-public roles from user profile
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I press "Add role"
    And I select "BioTerrorism Coordinator" from ext combo "rq[role]"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I press "Add"
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I press "Save"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | waiting for approval |

  Scenario: Add and remove a role then save
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Roles"
    And I press "Add role"
    And I select "BioTerrorism Coordinator" from ext combo "rq[role]"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I press "Add"
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I click role-item "BioTerrorism Coordinator"
    And I press "Remove role"
    Then I should not see "BioTerrorism Coordinator"
    When I press "Save"
    Then I should not see any errors
    And I should see "Requests sent"
