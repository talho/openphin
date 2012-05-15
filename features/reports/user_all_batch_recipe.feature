Feature: Generate a Report from the User-All-Batch-Recipe

  As a logged in user with a non-public role
  I can quickly generate reports from existing report recipe

  Background:
  #  Given the system builds all the user roles
  #  And the system builds all the user jurisdictions
    Given the report database system is ready
    And the following entities exist:
      | role         | Admin            |
      | role         | Medical Director |
      | role         | Public           |
      | jurisdiction | Texas            |
      | jurisdiction | Dallas           |
      | jurisdiction | Potter           |
    And Texas is the parent jurisdiction of:
      | Dallas | Potter |
    And the following users exist:
      | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
      | Dallas Admin    | dall.admin@example.com   | Admin            | Dallas         |
      | Dallas MD       | dall.md@example.com      | Medical Director | Dallas         |
      | Dallas Public   | dall.pub@example.com     | Public           | Dallas         |
      | Potter Admin    | pott.admin@example.com   | Admin            | Potter         |
      | Potter MD       | pott.md@example.com      | Medical Director | Potter         |
      | Potter Public   | pott.pub@example.com     | Public           | Potter         |
    And delayed jobs are processed
    And reports derived from the following recipes and authored by exist:
      | RecipeExternal::UserAllWithinJurisdictionsRecipe | dall.md@example.com |
      | RecipeExternal::UserAllBatchRecipe               | dall.md@example.com |

  @clear_report_db
  Scenario: Initiate the viewing of a report contents
    Given I am logged in as "pott.admin@example.com"
    And I navigate to "Reports"
    Then the "Reports" tab should be open
    And I should see "Recipes"

    When I wait for the "Fetching Recipe List" mask to go away
    And I click recipe-list-item "User All Batch Recipe"
    And I wait for the "recipe-list-item" element to finish
    And I press "Generate Report"
    And delayed jobs are processed
    And I click x-tbar-loading ""
    Then I should see "User-All-Batch-Recipe" in grid row 1

    When I click x-grid3-cell "User-All-Batch-Recipe"
    Then the "Report: User-All-Batch-Recipe" tab should be open
    And I should see "Users as of" within "#report-rendering"

    When I press "Copy" within "#report-rendering"
    And I choose "CSV Copy" within ".x-window"
    And I press "Copy" within ".x-window"
    And I navigate to "Documents"
    Then the "Documents" tab should be open
    And I should see "Reports" in grid row 2 within ".document-folder-tree-grid"

    When I select the "Reports" grid row
    Then I should see "User-All-Batch-Recipe.csv" within ".document-file-icon-view"

    When I navigate to "Reports"
    And I click x-grid3-cell "User-All-Batch-Recipe"
    Then the "Report: User-All-Batch-Recipe" tab should be open

    And I press "Copy" within "#report-rendering"
    And I choose "PDF Copy" within ".x-window"
    And I press "Copy" within ".x-window"
    And I navigate to "Documents"
    Then the "Documents" tab should be open
    And I should see "Reports" in grid row 2 within ".document-folder-tree-grid"

    When I select the "Reports" grid row
    Then I should see "User-All-Batch-Recipe.pdf" within ".document-file-icon-view"

    When I generate "Recipe::UserAllBatchRecipe" report
    And I inspect the generated pdf
    Then I should see "pott.md@example.com" in the pdf

    When I inspect the generated csv
    Then I should see "pott.md@example.com" in the csv
