Feature: School
  In order to view absentee and ILI surveillance data for a school
  As a permitted user
  I should see absentee and ILI graphs when I browse to the Rollcall School View screen

  Background:
    Given the following entities exist:
      | Role         | SchoolNurse     |
      | Role         | Epidemiologist  |
      | Jurisdiction | Texas           |
      | Jurisdiction | Houston         |
    And Texas is the parent jurisdiction of:
      | Houston |
    And Houston has the following school districts:
      | Houston ISD |
    And "Houston ISD" has the following schools:
      | Name        | SchoolID | Level |
      | LEWIS ES    | 1        | ES    |
      | SOUTHMAYDES | 2        | ES    |
      | BERRY ES    | 3        | ES    |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
      | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
      | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
      | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |
    And "Houston ISD" has the following current absenteeism data:
      | Day   | SchoolName  | Enrolled | Absent |
      | 0     | LEWIS ES    | 500      | 5      |
      | -1    | LEWIS ES    | 500      | 10     |
      | -2    | LEWIS ES    | 500      | 15     |
      | -3    | LEWIS ES    | 500      | 5      |
      | -4    | LEWIS ES    | 500      | 60     |
      | 0     | SOUTHMAYDES | 100      | 2      |
      | -1    | SOUTHMAYDES | 100      | 5      |
      | -2    | SOUTHMAYDES | 100      | 15     |
      | -3    | SOUTHMAYDES | 100      | 10     |
      | -4    | SOUTHMAYDES | 100      | 7      |
      | 0     | BERRY ES    | 200      | 10     |
      | -1    | BERRY ES    | 200      | 15     |
      | -2    | BERRY ES    | 200      | 5      |
      | -3    | BERRY ES    | 200      | 10     |
      | -4    | BERRY ES    | 200      | 10     |

  Scenario: Viewing the School View screen
    Given I am logged in as "nurse.betty@example.com"
    When I go to the dashboard page
    And I follow "Rollcall"
    Then I should see the following menu:
			| name | app_toolbar |
			| item | Main        |
      | item | School View |
    When I follow "School View"
    Then I should be on the rollcall schools page

  Scenario: Selecting a district and school from the dropdown
    Given I am logged in as "nurse.betty@example.com"
    When I go to the dashboard page
    And I follow "Rollcall"
    And I follow "School View"
    When I select "Houston ISD" from "District"
    And I press "Choose"
    And I select "LEWIS ES" from "School"
    And I press "Choose"
    Then I should see school data for "LEWIS ES"

  Scenario: Viewing the first school and going from there
    Given I am logged in as "nurse.betty@example.com"
    When I go to the rollcall schools page
    Then I should see school data for "BERRY ES"
    And I should see an absenteeism summary with the data:
      | Day | Percentage  |
      | 0   | 5.0         |
      | -1  | 7.5         |
      | -2  | 2.5         |
      | -3  | 5.0         |
      | -4  | 5.0         |
    When I follow "Next"
    Then I should see school data for "LEWIS ES"
    And I should see an absenteeism summary with the data:
      | Day | Percentage  |
      | 0   | 1.0         |
      | -1  | 2.0         |
      | -2  | 3.0         |
      | -3  | 1.0         |
      | -4  | 12.0        |
    When I follow "Next"
    Then I should see school data for "SOUTHMAYDES"
    Then I should not see the link "Next"
    When I follow "Prev"
    Then I should see school data for "LEWIS ES"
    When I follow "Prev"
    Then I should see school data for "BERRY ES"
    Then I should not see the link "Prev"