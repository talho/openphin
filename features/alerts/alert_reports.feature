Feature: Alert Reports
  In order to fulfill grant reporting requirements
  As an alerter
  I can view csv reports of an alert

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County   |
      | Jurisdiction | Tarrant County  |
      | Role         | HAN Coordinator |
      | Role         | Epidemiologist  |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | Brian Simms     | brian.simms@example.com    | Epidemiologist  | Tarrant County  |
    And a sent alert with:
      | author            | John Smith                      |
      | from_jurisdiction | Dallas County                   |
      | title             | Grant Sample                    |
      | jurisdictions     | Dallas County, Tarrant County   |
      | roles             | HAN Coordinator, Epidemiologist |

  Scenario: An alerter views a report of an alert
    Given the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I am on the alert log
    Then I should see an alert titled "Grant Sample"
    When I follow "Export"
    Then I should see the csv report for the alert titled "Grant Sample"

  Scenario: A non-alerter cannot view a report of an alert
    Given I am logged in as "john.smith@example.com"
    When I am on the alert log
    Then I should see an alert titled "Grant Sample"
    Then I should not see "Export"
