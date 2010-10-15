@ext
Feature: Custom Alert Reports
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
    And an alert with:
      | type              | Grant Inventory                                             |
      | author            | John Smith                                                  |
      | from_jurisdiction | Dallas County                                               |
      | title             | Grant Sample                                                |
      | jurisdictions     | Dallas County, Tarrant County                               |
      | roles             | Health Alert and Communications Coordinator, Epidemiologist |
    And delayed jobs are processed

  Scenario: An alerter views a report of an alert
    Given  I am logged in as "john.smith@example.com"
    And I am on the ext dashboard page
    And I navigate to "Alerts > View Alert Logs and Reports"
    Then I should see an alert titled "[Grant Inventory] Grant Sample"
    When I click "View" within alert "[Grant Inventory] Grant Sample"
    And I will confirm on next step
    When I click to download the file "Export as CSV"
    Then I should see "Success" within the alert box

  Scenario: A non-alerter cannot view a report of an alert
    Given I am logged in as "brian.simms@example.com"
    When I am on the ext dashboard page
    Then I should not be able to navigate to "Alerts > View Alert Logs and Reports"