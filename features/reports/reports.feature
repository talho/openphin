Feature: Test aspects of the report tab minus report schedules

  In order to view reporting functionality
  As a user
  I want to go to the report tab and create and view reports

  Background:
    Given I have navigated to the Reports tab

  Scenario: Create a report
    When I run a TestReport
    Then my TestReport should exist

  Scenario: View a report
    And I have a TestReport
    When I view the TestReport
    Then I should see my TestReport details

  Scenario: Delete a report
    And I have a TestReport
    When I delete the TestReport
    Then my TestReport should not exist
