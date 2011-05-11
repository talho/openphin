Feature: Removing public roles
In order to keep accurate records and avoid unnecessary alerts
as a user
I should be able to remove all but one public role from my profile

  Background:
    Given the following entities exist:
      | Jurisdiction  | Dallas County            |      |
      | Jurisdiction  | Potter County            |      |
      | Jurisdiction  | Texas                    |      |
      | role          | BioTerrorism Coordinator | phin |
 #   And the role "BioTerrorism Coordinator" is for the "phin" application
    And Federal is a foreign jurisdiction
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County  |
    And the following users exist:
      | John Smith    | john.smith@example.com   | Public | Dallas County |
      | John Smith    | john.smith@example.com   | Public | Texas         |
    And I am logged in as "john.smith@example.com"

  Scenario: Adding and removing public roles from user profile
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "Public" for "Potter County" in the RolesControl
    Then I should see the following within ".role-item":
      | Potter County | Public | needs to be saved |
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Dallas County | Public |
    And I should see the following within ".role-item":
      | Potter County | Public |

  Scenario: Cannot remove all public roles from user profile
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    And I should not see "Texas" within ".role-item"
    When I click profile-destroy "Dallas County"
    Then I should not see "Dallas County"
    When I press "Apply Changes"
    Then I should see "You must have at least one public role"
    And I should see the following within ".role-item":
      | Dallas County | Public |

  Scenario: Removing the all public roles from user profile and adding a new public role
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    Then I should not see "Texas" within ".role-item"
    And I click profile-destroy "Dallas County"
    Then I should see "No roles to display"
    When I press "Request Role"
    And I select "Public" from ext combo "rq[role]"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I press "Add"
    And I press "Apply Changes"
    Then I should see "Profile information saved"
    And I should see the following within ".role-item":
      | Potter County | Public |
    And I should not see "Texas" within ".role-item"
    And I should not see "Dallas County" within ".role-item"

  Scenario: Adding and removing non-public roles from user profile
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | waiting for approval |

  Scenario: Add and remove a role then save
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I click profile-destroy "BioTerrorism Coordinator"
    Then I should not see "BioTerrorism Coordinator"
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"

  Scenario: Adding a duplicate role
    BioTerrorism Coordinator
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | waiting for approval |

  Scenario: Add and remove a role then save
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    Then I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | needs to be saved |
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see the following within ".role-item":
      | Potter County | BioTerrorism Coordinator | waiting for approval |

  Scenario: Adding a duplicate role request
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    When I request the role "BioTerrorism Coordinator" for "Potter County" in the RolesControl
    And I press "Apply Changes"
    Then I should see "Role has already been requested for this jurisdiction"

  Scenario: Adding a role request duplicating an existing role membership
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"
    Then the "Manage Roles" tab should be open
    When I request the role "Public" for "Dallas County" in the RolesControl
    And I press "Apply Changes"
    Then I should see "User is already a member of this role and jurisdiction"
  
  Scenario: As a user the request role window should not display system-roles or foreign jurisdictions
    Given there is an system only Admin role
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com" 
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Roles"

    And I press "Request Role"
    And I open ext combo "rq[role]"
    Then I should see "BioTerrorism Coordinator"
    And I should not see "Admin"

    When I press "Request Role"
    And I open ext combo "Jurisdiction"
    Then I should see "Dallas County"
    And I should not see "Federal"

  Scenario: Role request window should not show roles for applications the user does not have
    When this scenario is written