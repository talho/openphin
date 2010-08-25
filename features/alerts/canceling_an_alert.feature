@alert
Feature: Canceling an alert

  In order to keep everyone informed with up to date information
  As an alerter
  I want to be able to send out a cancel alert

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County   |
      | Role         | Health Officer  |
      | Role         | HAN Coordinator |
    And the following users exist:
      | John Smith      | john.smith@example.com     | HAN Coordinator  | Dallas County  |
      | Jane Smith      | jane.smith@example.com     | HAN Coordinator  | Dallas County  |
      | Brian Simms     | brian.simms@example.com    | Health Officer  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com    | Health Officer  | Dallas County  |
      
    And the role "HAN Coordinator" is an alerter

  Scenario: Canceling an alert
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | Flying Monkey Disease                 |
      | Message               | For more details, keep on reading...  |
      | Short Message         | For more details, keep on reading...  |
      | Acknowledge           | None                                  |
      | Communication methods | E-mail                                |
      | Severity              | Moderate                              |
      | Status                | Actual                                |
      | Delivery Time         | 72 hours                              |
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
    And I press "Preview Message"
    Then I should see a preview of the message with:
        | Roles | Health Officer |
    When I press "Send"
    Then I should see "Successfully sent the alert"

    When I go to cancel the alert
    And I make changes to the alert form with:
      | Message    | Flying monkey disease is not contagious |
    And I press "Preview Message"

    Then I should see a preview of the message with:
      | Jurisdictions         | Dallas County                           |
      | Roles                 | Health Officer                          |
      | Title                 | [Cancel] - Flying Monkey Disease        |
      | Message               | Flying monkey disease is not contagious |
      | Severity              | Moderate                                |
      | Status                | Actual                                  |
      | Acknowledge           | No                                      |
      | Communication methods | E-mail                                  |
      | Delivery Time         | 72 hours                                |
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alert log
    And I should see an alert titled "[Cancel] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Health Alert "[Cancel] - Flying Monkey Disease"  |
      | body contains | Title: [Cancel] - Flying Monkey Disease          |
      | body contains | Alert ID:                                        |
      | body contains | Reference:                                       |
      | body contains | Agency: Dallas County                            |
      | body contains | Sender: John Smith                               |
      | body contains | Flying monkey disease is not contagious          |

  Scenario: Cancelling an alert as another alerter within the same jurisdiction
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts

    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | Flying Monkey Disease                 |
      | Message               | For more details, keep on reading...  |
      | Short Message         | For more details, keep on reading...  |
      | Acknowledge           | None                                  |
      | Communication methods | E-mail                                |
      | Severity              | Moderate                              |
      | Status                | Actual                                |
      | Delivery Time         | 72 hours                              |
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | Roles | Health Officer |
    When I press "Send"
    Then I should see "Successfully sent the alert"

    When I am on the alert log
    Then I should see an alert titled "Flying Monkey Disease"

    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts
    When I am on the alert log
    Then I should see an alert titled "Flying Monkey Disease"
    When I go to cancel the alert
    And I make changes to the alert form with:
      | Message    | Flying monkey disease is not contagious |
    And I press "Preview Message"

    Then I should see a preview of the message with:
      | Jurisdictions         | Dallas County                           |
      | Roles                 | Health Officer                          |
      | Title                 | [Cancel] - Flying Monkey Disease        |
      | Message               | Flying monkey disease is not contagious |
      | Severity              | Moderate                                |
      | Status                | Actual                                  |
      | Acknowledge           | No                                      |
      | Communication methods | E-mail                                  |
      | Delivery Time         | 72 hours                                |

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alert log
    And I should see an alert titled "[Cancel] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | [Cancel] - Flying Monkey Disease                 |
      | body contains | Title: [Cancel] - Flying Monkey Disease          |
      | body contains | Alert ID:                                        |
      | body contains | Reference:                                       |
      | body contains | Agency: Dallas County                            |
      | body contains | Sender: John Smith                               |
      | body contains | Flying monkey disease is not contagious          |

  Scenario: Make sure re-submitting a cancellation after alert is canceled doesn't work
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts

    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | Flying Monkey Disease                 |
      | Message               | For more details, keep on reading...  |
      | Short Message         | For more details, keep on reading...  |
      | Acknowledge           | None                                  |
      | Communication methods | E-mail                                |
      | Severity              | Moderate                              |
      | Status                | Actual                                |
      | Delivery Time         | 72 hours                              |
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | Roles | Health Officer |
    When I press "Send"
    Then I should see "Successfully sent the alert"

    When I go to cancel the alert
    And I make changes to the alert form with:
      | Message    | Flying monkey disease is not contagious |
    And I press "Preview Message"
    When I press "Send"
    Then I should see "Successfully sent the alert"
    When I re-submit a cancellation for "Flying Monkey Disease"
    Then I should see "You cannot update or cancel an alert that has already been cancelled."
    And I should be on the alert log
    And I should see 2 alerts
