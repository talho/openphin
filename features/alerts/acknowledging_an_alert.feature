Feature: Acknowledging an alert

  In order to report that I read an alerts
  As a user
  I can acknowledge an alert
  
  Background:
    Given the following entities exist:
      | Jurisdiction | Dallas County                               |
      | Role         | Health Alert and Communications Coordinator |
    And the following users exist:
      | Martin Fowler      | martin@example.com   | Health Alert and Communications Coordinator | Dallas County |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "martin@example.com"
    
  Scenario: A user acknowledging an alert via the HAN
    Given a sent alert with:
      | title             | Piggy Pox            |
      | message           | the world is on fire |
      | status            | Actual               |
      | severity          | Moderate             |
      | acknowledge       | Yes                  |
      | from_jurisdiction | Dallas County        |
      | jurisdictions     | Dallas County        |
    When I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
    And I click alert "Piggy Pox"
    When I press "Acknowledge"
    Then I have acknowledged the alert for "Piggy Pox"

    When I go to the HAN
    And I click alert "Piggy Pox"
    Then I should not see an "Acknowledge" button
    But I should see "Acknowledge: Yes"

  Scenario: A user acknowledges an alert with a call down response via the HAN
    Given a sent alert with:
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
    When I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
    And I click alert "Piggy Pox"
    And I select "if you can respond within 30 minutes" from "Alert Response"
    When I press "Acknowledge"
    Then I have acknowledged the alert for "Piggy Pox"

    When I go to the HAN
    And I click alert "Piggy Pox"
    Then I should not see an "Acknowledge" button
    And I should not see "Alert Response"
    But I should see "Acknowledge: if you can respond within 30 minutes"
    And the alert should be acknowledged

   Scenario: A user can not acknowledge an alert with a call down response *without* selecting a response
    Given a sent alert with:
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
    When I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
     And I click alert "Piggy Pox"
    When I will confirm on next step
    Then I press "Acknowledge"
    Then I should see "You must select a response" within the alert box
    And the alert should not be acknowledged

  Scenario: User can acknowledge an alert after 'expiration' but during the grace period
    #assuming the default of 4 hour grace
    Given a sent alert with:
      | title             | Piggy Pox                            |
      | message           | the world is on fire                 |
      | status            | Actual                               |
      | severity          | Moderate                             |
      | acknowledge       | Yes                                  |
      | delivery time     | 24 hours                             |
      | from_jurisdiction | Dallas County                        |
      | jurisdictions     | Dallas County                        |
    And 26 hours pass
    And I am on the HAN
    Then I can see the alert summary for "Piggy Pox"
    And I click alert "Piggy Pox"
    And I press "Acknowledge"
    And the latest alert should be acknowledged

#  TODO: Fix this
#  Scenario: User cannot acknowledge an alert that has expired
#    Given a sent alert with:
#      | title             | Piggy Pox                            |
#      | message           | the world is on fire                 |
#      | status            | Actual                               |
#      | severity          | Moderate                             |
#      | acknowledge       | Yes                                  |
#      | delivery time     | 24 hours                             |
#      | from_jurisdiction | Dallas County                        |
#      | jurisdictions     | Dallas County                        |
#    And 30 hours pass
#    And I am on the HAN
#    Then I can see the alert summary for "Piggy Pox"
#    And I click alert "Piggy Pox"
#    Then I should see "Acknowledgement is no longer allowed for this Alert"