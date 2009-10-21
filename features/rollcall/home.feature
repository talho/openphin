Feature: Rollcall status screen
  In order to view general information about school surveillance data
  As a permitted user
  I should see status information when I browse to the Rollcall Home screen

  Background:
    Given the following entities exist:
      | Role         | SchoolNurse     |
      | Role         | Epidemiologist  |
      | Jurisdiction | Texas           |
      | Jurisdiction | Houston         |
    And Texas is the parent jurisdiction of:
      | Houston |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
      | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
      | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
      | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |

Scenario: Accessing the Rollcall application
  Given I am logged in as "nurse.betty@example.com"
  When I go to the dashboard page
  Then I should see the following menu:
    | name | portal_toolbar |
    | item | Rollcall       |
  
Scenario: Viewing the Home screen
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see the following menu:
			| name | app_toolbar |
			| item | Main        |
			