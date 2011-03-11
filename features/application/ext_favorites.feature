@ext
Feature: User should be able to set values as favorites

  As a user
  I want to be able to drag a tab into the favorites toolbar
  So I can access this as one of my bookmarks

  Background:
    Given the following users exist:
          | Martin Fowler      | martin@example.com   | Health Official | Dallas County |
    And I am on the dashboard page
    And I am logged in as "martin@example.com"
    And I have a favorite named "Test Favorite"
    And I am on the ext dashboard page

  Scenario: User Creates Favorite
    When I navigate to "HAN > HAN Alerts"
    Then the "HAN Alerts" tab should be open
    When I drag the "HAN Alerts" tab to "#favoritestoolbar"
    And I wait for the "Saving" mask to go away
    And I should see "HAN Alerts" within "#favoritestoolbar"
    When I navigate to "Martin Fowler > Bookmarks"
    Then I should see the following ext menu items:
      | name                       |
      | Test Favorite              |
      | HAN Alerts                 |
      | Hide the Bookmarks Toolbar |
      | Manage Bookmarks           |

  Scenario: Clicking on a favorite opens that tab and opens only one tab
    When I click favorite_button "Test Favorite"
    Then the "Test Favorite" tab should be open
    When I click x-tab-right "Dashboard"
    Then the "Test Favorite" tab should be open and inactive
    When I click favorite_button "Test Favorite"
    Then the "Test Favorite" tab should be open and active
    And I should see "Test Favorite" 1 time within ".x-tab-strip"

  Scenario: User can remove a favorite through right click
    When I right click favorite button "Test Favorite"
    And I click x-menu-item "Remove"
    And I wait for the "Saving" mask to go away
    Then I should not see "Test Favorite"
    When I navigate to "Martin Fowler > Bookmarks"
    Then I should see the following ext menu items:
      | name                       |
      | Hide the Bookmarks Toolbar |
      | Manage Bookmarks           |
    And I should not see the following ext menu items:
      | name          |
      | Test Favorite |

  Scenario: User can view and remove favorites through manage favorites
    When I navigate to "Martin Fowler > Bookmarks > Manage Bookmarks"
    Then the "Manage Bookmarks" window should be open
    When I will confirm on next step
    When I click removeBtn on the "Test Favorite" grid row
    And I wait for the "Saving" mask to go away
    Then I should not see "Test Favorite"

  Scenario: User cannot create duplicate favorite
    When I navigate to "HAN > HAN Alerts"
    Then the "HAN Alerts" tab should be open
    When I drag the "HAN Alerts" tab to "#favoritestoolbar"
    And I wait for the "Saving" mask to go away
    And I drag the "HAN Alerts" tab to "#favoritestoolbar"
    Then I should not see "Saving"
    And I should see "HAN Alerts" 1 time within "#favoritestoolbar"