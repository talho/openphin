@ext
Feature: Application layout should have communications, portal & application toolbars
  As a user
  I want to see applications that are important to me in the portal toolbar and
  functions specific to the application in the application toolbar and
  communications and utility functions in the communication toolbar
  So that I can navigate the OpenPHIN portal with ease

  Background:
    Given the following users exist:
      | Martin Fowler      | martin@example.com   | Health Official | Dallas County |
    And the following entities exist:
      | Jurisdiction   | Texas |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com    |
    And an article exists
    And an article exists
    And an article exists
    And an article exists
    And an article exists

  Scenario: Viewing the dashboard as a user
    Given I am logged in as "martin@example.com"
    When I go to the ext dashboard page
    Then I should have "#tabpanel" within "#centerpanel"
    And I should have "#favoritestoolbar" within "#centerpanel"
    And the "Home" tab should be open

  Scenario: Viewing the portal and comm toolbar as a user
    Given I am logged in as "martin@example.com"
    When I go to the ext dashboard page
    Then I should see the following toolbar items in "top_toolbar":
      | HAN                  |
      | Rollcall             |
      | FAQs                 |
      | Forums               |
      | Tutorials            |
      | My Dashboard         |
      | My Account           |
      | About TXPHIN         |
      | Sign Out             |
    And I should see the following toolbar items in "bottom_toolbar":
      | Calendar             |
      | Chat                 |
      | Documents            |
      | Links                |
    When I press "HAN" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name                    |
      | HAN Home                |
      | Send an Alert           |
      | Alert Log and Reporting |
    When I press "FAQs" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name                            |
      | H1N1 Frequently Asked Questions |
    When I press "Tutorials" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name            |
      | PHIN            |
      | HAN             |
      | Documents Panel |
      | Forums          |
      | Rollcall        |
    When I press "My Account" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name          |
      | Profile       |
      | Request Roles |
    #And I should see 4 "article" sections

  Scenario: Seeing the Administrator menu as an admin
    Given I am logged in as "joe.smith@example.com"
    When I go to the ext dashboard page
    And I press "Admin" within "#top_toolbar"
    Then I should see the following ext menu items:
      | name                  |
      | Manage Roles          |
      | Manage Groups         |
      | Manage Users          |
      | Manage Invitations    |
    # Need to look for the other admin menu options here
    When I click x-menu-item "Manage Roles" within ".x-menu"
    And I wait until I have 2 ext menus
    Then I should see the following ext menu items:
      | name                  |
      | Pending Role Requests |
      | Assign Roles          |
    When I click x-menu-item "Manage Users" within ".x-menu"
    And I wait until I have 3 ext menus
    Then I should see the following ext menu items:
      | name          |
      | Add a User    |
      | Batch Users   |
      | Delete a User |
    When I click x-menu-item "Manage Invitations" within ".x-menu"
    And I wait until I have 4 ext menus
    Then I should see the following ext menu items:
      | name             |
      | Invite Users     |
      | View Invitations |


  Scenario: Non-admins should not see the Admin link
    Given I am logged in as "martin@example.com"
    When I go to the ext dashboard page
    Then I should not see "Admin" within "#top_toolbar"

  Scenario: Public-only members should not see advanced search
    Given the user "publico publican" with the email "public@example.com" has the role "Public" in "Texas"
    Given I am logged in as "public@example.com"
    When I go to the ext dashboard page
    Then I should not see "Find People" within "#top_toolbar"


