Feature: Importing automated data
  In order to facilitate reliable surveillance of school attendance data
  As an outside system
  I want to upload data for automatic import into Rollcall

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
      | BERRY ES    | 3        | ES    |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | Rollcall    | Houston |
    And "Houston ISD" has the following current absenteeism data:
      | Day   | SchoolName  | Enrolled | Absent |
      | -1    | LEWIS ES    | 500      | 10     |
      | -2    | LEWIS ES    | 500      | 15     |
      | -3    | LEWIS ES    | 500      | 5      |
      | -4    | LEWIS ES    | 500      | 60     |
      | -1    | BERRY ES    | 200      | 20     |
      | -2    | BERRY ES    | 200      | 10     |
      | -3    | BERRY ES    | 200      | 10     |
      | -4    | BERRY ES    | 200      | 10     |


  Scenario: Uploading a file
    Given I am logged in as "nurse.betty@example.com"
    When I drop the following file in the rollcall directory:
    """
    <%= Date.today.strftime("%Y-%m-%d 00:00:00")%>|LEWIS ES|500|50
    <%= Date.today.strftime("%Y-%m-%d 00:00:00")%>|BERRY ES|200|30
    """
    And the rollcall background worker processes
    And I load the rollcall school page for "LEWIS ES"
    Then I should see an absenteeism graph with the following:
    | data        | nil,nil,12.0,1.0,3.0,2.0,10.0     |
    | data-label  | LEWIS ES                          |
    | title       | Absenteeism Rates (Last 7 days)   |

