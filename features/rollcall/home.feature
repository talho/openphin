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
    And Houston has the following school districts:
      | Houston ISD |
    And "Houston ISD" has the following schools:
      | Name        | SchoolID | Level |
      | LEWIS ES    | 1        | ES    |
      | SOUTHMAYDES | 2        | ES    |
      | BERRY ES    | 3        | ES    |
      | BURRUS ES   | 4        | ES    |
      | ELIOTES     | 5        | ES    |
      | FLEMING MS  | 6        | ES    |
      | SICKKIDS ES | 7        | ES    |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
      | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
      | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
      | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |
    And "Houston ISD" has the following absenteeism data:
      | Date  | Time     | SchoolName  | Enrolled | Absent |
      | today | 00:00:00 | LEWIS ES    | 809      | 36     |
      | today | 00:00:00 | SOUTHMAYDES | 704      | 22     |
      | today | 00:00:00 | BERRY ES    | 623      | 34     |
      | today | 00:00:00 | BURRUS ES   | 387      | 15     |
      | today | 00:00:00 | ELIOTES     | 570      | 20     |
      | today | 00:00:00 | FLEMING MS  | 536      | 14     |
      | today | 00:00:00 | SICKKIDS ES | 200      | 30     |

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

Scenario: Seeing the average absenteeism graph(s)
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see an average absenteeism graph with the data:
    | today | 00:00:00 | LEWIS ES    | 809 | 36 |
    | today | 00:00:00 | SOUTHMAYDES | 704 | 22 |
    | today | 00:00:00 | BERRY ES    | 623 | 34 |
    | today | 00:00:00 | BURRUS ES   | 387 | 15 |
    | today | 00:00:00 | ELIOTES     | 570 | 20 |
    | today | 00:00:00 | FLEMING MS  | 536 | 14 |
    | today | 00:00:00 | SICKKIDS ES | 200 | 30 |

Scenario: Seeing the abseentism alert summary
  Given I am logged in as "nurse.betty@example.com"
  When I go to the rollcall page
  Then I should see an "orange" rollcall alert for "SICKKIDS ES" with 15% absenteeism
  And I should not see a rollcall alert for "BERRY ES"
