@ext
Feature: Sending alerts to SMS devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my SMS device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                              | Wise County    |
    And "keith.gaddis@example.com" has the following devices:
      | sms | 2105551212 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to SMS devices
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send a HAN Alert"
    When I fill in the ext alert defaults
    And I check "SMS"
    And I fill in "Caller ID" with "4114114111"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak short message"
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I send the alert

    When delayed jobs are processed
    Then the following SMS calls should be made:
      | sms         | message                            |
      | 12105551212 | Chicken pox outbreak short message |