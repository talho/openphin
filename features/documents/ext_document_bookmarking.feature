@ext
Feature: Receiving notifications to different events

  In order to directly access document folders and shares
  As a user
  I want to bookmark folders and return to them

  Background:
    Given the following entities exist:
      | Jurisdiction  | Hazard County      |
      | Role          | Mechanic           |
      | Role          | Sheriff            |
    And Georgia is the parent jurisdiction of:
      | Hazard County |
    And the following users exist:
      | Bo Duke   | bo@example.com       | Mechanic | Hazard County  |
      | Boss Hogg | bosshogg@example.com | Sheriff  | Hazard County  |
    And delayed jobs are processed

Scenario: Bookmarking folders by dragging a tab
  Given I am logged in as "bosshogg@example.com"
  And I create a folder outline with "Warrants"
  And I navigate to "Documents"
  Then I should see "Warrants"

  When I select the "Warrants" grid row
  And I wait for the "Loading" mask to go away
  When I click x-layout-collapsed ""
  And I drag the "Documents: Warrants" tab to "#favoritestoolbar"
  And I wait for the "Saving" mask to go away
  And I should see "Documents: Warrants" within "#favoritestoolbar"
  When I navigate to "Boss Hogg > Bookmarks"
  Then I should see the following ext menu items:
    | name                       |
    | Documents: Warrants        |
    | Hide the Bookmarks Toolbar |
    | Manage Bookmarks           |
  When I close the active tab
  Then the "Documents: Warrants" tab should not be open
  When I click favorite_button "Documents: Warrants"
  Then the "Documents: Warrants" tab should be open

Scenario: Bookmarking folders by dragging the folder icon 
  Given I am logged in as "bo@example.com"
  And I create a folder outline with "Jorts"
  And I navigate to "Documents"
  Then I should see "Jorts"

  When I click x-layout-collapsed ""
  When I drag the "Jorts" folder to "#favoritestoolbar"
  And I wait for the "Saving" mask to go away
  And I should see "Documents: Jorts" within "#favoritestoolbar"
  When I navigate to "Bo Duke > Bookmarks"
  Then I should see the following ext menu items:
    | name                       |
    | Documents: Jorts           |
    | Hide the Bookmarks Toolbar |
    | Manage Bookmarks           |
  When I close the active tab
  Then the "Documents: Jorts" tab should not be open
  When I click favorite_button "Documents: Jorts"
  Then the "Documents: Jorts" tab should be open

Scenario: Bookmarking another user's share
  Given I am logged in as "bo@example.com"
  And I create a folder outline with "Moonshine"
  And I navigate to "Documents"
  Then I should see "Moonshine"
  And I click folder-context-icon on the "Moonshine" grid row
  And I click x-menu-item "Edit Folder"
  And I click x-tab-strip-text "Sharing"
  And I choose "Shared - Accessible to the audience specified below"
  And I select the following in the audience panel:
    | name       | type  |
    | Boss Hogg  | User  |
  And I press "Save"
  And I wait for the "Saving" mask to go away
  And I sign out

  When I am logged in as "bosshogg@example.com"
  And I navigate to "Documents"
  And I expand the folders "Bo Duke"
  Then I should see "Moonshine"
  When I select the "Moonshine" grid row
  And I wait for the "Loading" mask to go away
  When I click x-layout-collapsed ""
  And I drag the "Documents: Moonshine" tab to "#favoritestoolbar"
  And I wait for the "Saving" mask to go away
  And I should see "Documents: Moonshine" within "#favoritestoolbar"
  When I navigate to "Boss Hogg > Bookmarks"
  Then I should see the following ext menu items:
    | name                       |
    | Documents: Moonshine       |
    | Hide the Bookmarks Toolbar |
    | Manage Bookmarks           |
  When I close the active tab
  Then the "Documents: Moonshine" tab should not be open
  When I click favorite_button "Documents: Moonshine"
  Then the "Documents: Moonshine" tab should be open