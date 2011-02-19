@ext
Feature: Users with an alerter role

  Scenario: Sending an alert without an alerter role
    Given the following users exist:
      | John Smith      | john.smith@example.com     | Health Officer  | Dallas County  |
    And I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    Then I should not be able to navigate to "HAN > Send Alert"

  Scenario: Sending an alert with multiple alerter roles