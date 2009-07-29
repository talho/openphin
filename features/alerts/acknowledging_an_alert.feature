Feature: Acknowledging an alert
  In order to report that I read an alerts
  As a user
  I can acknowledge an alert
  
  Background:
    Given the following users exist:
      | Martin Fowler      | martin@example.com   | Health Official | Dallas County |
    And the role "Health Official" is an alerter
    And a sent alert with:
      | title       | Piggy Pox |
      | message     | the world is on fire |
      | status      | Actual   |
      | severity    | Moderate |
      | acknowledge | Yes      |
      | from_jurisdiction | Dallas County |
      | jurisdictions | Dallas County |
    And I am logged in as "martin@example.com"
    
  Scenario: A user acknowledging an alert via the web
    When I am on the alert log
    And I click "View" on "Piggy Pox"
    Then I can see the alert summary for "Piggy Pox"
    When I press "Acknowledge"
    Then I have acknowledged the alert for "Piggy Pox"