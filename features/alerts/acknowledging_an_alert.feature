Feature: Acknowledging an alert

  In order to report that I read an alerts
  As a user
  I can acknowledge an alert
  
  Background:
    Given the following users exist:
      | Martin Fowler      | martin@example.com   | Health Official | Dallas County |
    And the role "Health Official" is an alerter
    And I am logged in as "martin@example.com"
    
  Scenario: A user acknowledging an alert via the HAN
    Given a sent alert with:
      | title       | Piggy Pox |
      | message     | the world is on fire |
      | status      | Actual   |
      | severity    | Moderate |
      | acknowledge | Yes      |
      | from_jurisdiction | Dallas County |
      | jurisdictions | Dallas County |
    When I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
    And I follow "More"
    When I press "Acknowledge"
    Then I have acknowledged the alert for "Piggy Pox"
    
    When I go to the HAN
    And I follow "More"
    Then I should not see an "Acknowledge" button
    But I should see "Acknowledge: Yes"
    
  Scenario: A user acknowledges an alert with a call down response via the HAN
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
      | alert_response_1 | if you can respond within 15 minutes |
      | alert_response_2 | if you can respond within 30 minutes |
      | alert_response_3 | if you can respond within 1 hour     |
      | alert_response_4 | if you can respond within 4 hours    |
      | alert_response_5 | if you cannot respond                |
    And I am logged in as "martin@example.com"
    When I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
    And I follow "More"
    And I select "if you can respond within 30 minutes" from "Alert Response"
    When I press "Acknowledge"
    Then I have acknowledged the alert for "Piggy Pox"
  
    When I go to the HAN
    And I follow "More"
    Then I should not see an "Acknowledge" button
    And I should not see "Alert Response"
    But I should see "Acknowledge: if you can respond within 30 minutes"
    


