Feature: Alert Reports
  In order to fulfill grant reporting requirements
  As an alerter
  I can view csv reports of an alert

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County                               |
      | Jurisdiction | Tarrant County                              |
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Epidemiologist                              |
    And the following users exist:
      | John Smith      | john.smith@example.com  | Health Alert and Communications Coordinator | Dallas County  |
      | Brian Simms     | brian.simms@example.com | Epidemiologist                              | Tarrant County |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And a sent alert with:
      | author            | John Smith                                                  |
      | from_jurisdiction | Dallas County                                               |
      | title             | Grant Sample                                                |
      | jurisdictions     | Dallas County, Tarrant County                               |
      | roles             | Health Alert and Communications Coordinator, Epidemiologist |

  Scenario: An alerter views a report of an alert
    Given  I am logged in as "john.smith@example.com"
    When I am on the alert log
    Then I should see an alert titled "Grant Sample"
    When I follow "View"
    And I will confirm on next step
    When I download the file "Export Contacted Users (CSV)"
    Then I should see "Success" within the alert box

  Scenario: A non-alerter cannot view a report of an alert
    Given I am logged in as "brian.simms@example.com"
    When I am on the alert log
    Then I should see "You do not have permission to send an alert."
    And I should not see an alert titled "Grant Sample"
    And I should not see "Export"