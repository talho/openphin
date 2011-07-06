Feature: Generate a Report

  As a logged in user with a non-public role
  I can quickly generate reports from existing report recipe

Background:
  Given the following entities exist:
    | role         | Admin            |
    | role         | Medical Director |
    | role         | Public           |
    | jurisdiction | Texas            |
    | jurisdiction | Dallas County    |
    | jurisdiction | Potter County    |
  And Texas is the parent jurisdiction of:
    | Dallas County | Potter County |
  And the following users exist:
    | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
    | Dallas Admin    | dall.admin@example.com   | Admin            | Dallas County  |
    | Dallas MD       | dall.md@example.com      | Medical Director | Dallas County  |
    | Dallas Public   | dall.pub@example.com     | Public           | Dallas County  |
    | Potter Admin    | pott.admin@example.com   | Admin            | Potter County  |
    | Potter MD       | pott.md@example.com      | Medical Director | Potter County  |
    | Potter Public   | pott.pub@example.com     | Public           | Potter County  |
  And delayed jobs are processed
  And the following reports exist:
    | UserAllRecipe          | dall.md@example.com |
    | UserFirstHundredRecipe | dall.md@example.com |
    | UserAllBatchRecipe     | dall.md@example.com |

Scenario: Public-only user can not navigate to Reports
  Given I am logged in as "dall.pub@example.com"
  When I navigate to the ext dashboard page
  And I wait for the "Loading PHIN" mask to go away
  Then I should see the following toolbar items in "top_toolbar":
    | Dallas Public |
  And I should not see the following toolbar items in "top_toolbar":
    | Reports |

  Scenario: Users with non-public role can navigate to Reports
  Given I am logged in as "dall.md@example.com"
  When I navigate to the ext dashboard page
  And I wait for the "Loading PHIN" mask to go away
  Then I should see the following toolbar items in "top_toolbar":
      | Reports |

Scenario: View report recipes and their description
  Given I am logged in as "pott.md@example.com"
  When I navigate to the ext dashboard page
  And I navigate to "Reports"
  Then I should see "Recipes"
  And the "Reports" tab should be open
  And I should see "recipe description"

  When I wait for the "Fetching Recipe List" mask to go away
  And I click recipe-list-item "User All Recipe"
  Then I should see "Report of all users"
  And I should see "Generate Report"

  When I press "Clear"
  Then I should not see "Report of all users"
  And I should see "recipe description"
  And I should not see "Generate Report"

Scenario: Generate a report from a report-recipe
  Given I am logged in as "pott.md@example.com"
  When I navigate to the ext dashboard page
  And I navigate to "Reports"
  Then I should see "Recipes"
  And the "Reports" tab should be open

  When I wait for the "Fetching Recipe List" mask to go away
  And I click recipe-list-item "User All Recipe"
  And I wait for the "recipe-list-item" element to finish
  And I should see "Generate Report"

Scenario: Initiate the viewing of a report contents
  Given I am logged in as "pott.md@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Reports"
  Then the "Reports" tab should be open
  And I should see "Recipes"

  When I wait for the "Fetching Recipe List" mask to go away
  And I click recipe-list-item "User All Recipe"
  And I wait for the "recipe-list-item" element to finish
  And I should see "Generate Report"
  And I press "Generate Report"
  And delayed jobs are processed
  And I should see "User All Recipe" in grid row 1 within ".report-results"
  When I click x-grid3-cell "User All Recipe"
  Then the "Report: User All Recipe" tab should be open

  Scenario: View, sort and paginate previously generated reports
  Given I am logged in as "dall.md@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Reports"
  Then the "Reports" tab should be open

  Then I should see "Displaying results 1 - 3 of 3"
  And I should see "User All Batch Recipe" in grid row 1 within ".report-results"
  And I should see "User All Recipe" in grid row 3 within ".report-results"

  When I click x-grid3-hd-inner "Report ID"
  Then the "Report ID" grid header is sorted ascending
  And I should see "User All Batch Recipe" in grid row 3 within ".report-results"
  And I should see "User All Recipe" in grid row 1 within ".report-results"

  When I click x-grid3-hd-inner "Report ID"
  Then the "Report ID" grid header is sorted descending
  And I should see "User All Batch Recipe" in grid row 1 within ".report-results"
  And I should see "User All Recipe" in grid row 3 within ".report-results"

  When I click x-grid3-hd-inner "Recipe"
  Then the "Recipe" grid header is sorted ascending
  And I should see "User All Batch Recipe" in grid row 3 within ".report-results"
  And I should see "User All Recipe" in grid row 1 within ".report-results"

  When I click x-grid3-hd-inner "Recipe"
  Then the "Recipe" grid header is sorted descending
  And I should see "User All Batch Recipe" in grid row 1 within ".report-results"
  And I should see "User All Recipe" in grid row 3 within ".report-results"

  When I click x-grid3-hd-inner "Generated at"
  Then the "Generated at" grid header is sorted ascending

  When I click x-grid3-hd-inner "Generated at"
  Then the "Generated at" grid header is sorted descending

    When I click x-grid3-hd-inner "Resultset size"
    Then the "Resultset size" grid header is sorted ascending

    When I click x-grid3-hd-inner "Resultset size"
    Then the "Resultset size" grid header is sorted descending

    When I click x-grid3-hd-inner "Rendered at"
    Then the "Rendered at" grid header is sorted ascending

    When I click x-grid3-hd-inner "Rendered at"
    Then the "Rendered at" grid header is sorted descending

    When I click x-grid3-hd-inner "Render size"
    Then the "Render size" grid header is sorted ascending

    When I click x-grid3-hd-inner "Render size"
    Then the "Render size" grid header is sorted descending

  When the following reports exist:
    | UserFirstHundredRecipe | dall.md@example.com |
    | UserAllRecipe          | dall.md@example.com |
    | UserAllRecipe          | dall.md@example.com |
    | UserFirstHundredRecipe | dall.md@example.com |
    | UserAllRecipe          | dall.md@example.com |
    | UserAllRecipe          | dall.md@example.com |
    | UserAllRecipe          | dall.md@example.com |
    | UserFirstHundredRecipe | dall.md@example.com |
  And I close the active tab
  And I navigate to "Reports"
  Then I should see "Displaying results 1 - 10 of 11"

