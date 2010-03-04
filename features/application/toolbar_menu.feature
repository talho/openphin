Feature: Application toolbars should have menus
  As a admin
  I should see a menu when a toolbar item is selected

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And Texas has the following administrators:
      | Martin Fowler | martin@example.com |
    And I am logged in as "martin@example.com"

  Scenario: Admin application has toolbar Manage Roles with menu
    Then I should see "Admin"
    When I follow "Admin"
    Then I should see "Manage Roles"
    When I follow "Manage Roles"
    Then I should see "Manage Roles"
    And I should see "Pending Role Requests"
    And I should see "Assign Roles"
  Scenario: Admin application has toolbar Manage Users with menu
    Then I should see "Admin"
    When I follow "Admin"
    Then I should see "Manage Users"
    When I follow "Manage Users"
    Then I should see "Manage Users"
    And I should see "Add a User"
    And I should see "Batch Users"
    And I should see "Delete a User"
  Scenario: Admin application has toolbar Manage Groups without a menu
    Then I should see "Admin"
    When I follow "Admin"
    Then I should see "Manage Groups"
    When I follow "Manage Groups"
  Scenario: Admin application has toolbar Manage Invitations with a menu
    Then I should see "Admin"
    When I follow "Admin"
    Then I should see "Manage Invitations"
    When I follow "Manage Invitations"
    And I should see "Invite Users"
    And I should see "View Invitations"
    
