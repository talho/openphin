Feature: Report Schedules

  In order to receive a report every morning
  As a user
  I want to be able to schedule reports by day

  Background:
    Given I have navigated to the Reports tab

  Scenario: Create report schedule
    Given I have opened the Scheduled Reports section
    When I schedule TestReport
    Then TestReport should be on my schedule

  Scenario: Change report schedule
    Given I have scheduled TestReport
    And I have opened the Scheduled Reports section
    When I modify TestReport
    Then TestReport should be on a new schedule

  Scenario: Cannot create duplicate report schedule
    Given I have scheduled TestReport
    And I have opened the Scheduled Reports section
    When I schedule TestReport
    Then I should only have one TestReport scheduled

  Scenario: Backgroundrb triggers report
    Given I have scheduled TestReport
    When backgroundrb runs report_worker
    Then my TestReport should exist
