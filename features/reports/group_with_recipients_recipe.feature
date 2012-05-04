@ext
Feature: Create a groups report
  As a logged in user with a non-public role
  I can quickly generate reports from existing report recipe

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
    When delayed jobs are processed

  @clear_report_db
  Scenario:
    Given I am logged in as "jill.smith@example.com"
    And I generate "RecipeInternal::GroupWithRecipientsRecipe" report on "Group" named "Dallas County Health Officer Group"

    When I inspect the generated pdf
    Then I should see "Dallas County Health Officer Group" in the pdf
    And I should see "Health Officer2" in the pdf
    And I should see "ho1@example.com" in the pdf
    And I should see "Health Officer in Dallas County" in the pdf

    When I inspect the generated csv
    Then I should see "display_name" in the csv
    And I should see "Health Officer2" in the csv

    And I should see "email" in the csv
    And I should see "ho1@example.com" in the csv

    And I should see "role_memberships" in the csv
    And I should see "Health Officer in Dallas County" in the csv


