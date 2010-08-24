Feature: Updating an alert

  In order to keep everyone informed with up to date information
  As an alerter
  I want to be able to send out an update to an alert

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
    And delayed jobs are processed

  Scenario: Updating an alert
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert "Details" form with:
      | Title         | Flying Monkey Disease                |
      | Message       | For more details, keep on reading... |
      | Severity      | Moderate            |
      | Status        | Actual              |
      | Acknowledge   | None                |
      | Delivery Time | 72 hours            |
    And I check "E-mail"
    And I press "Select an Audience"
    And delayed jobs are processed
    And I fill out the alert "Audience" form with:
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
      | People   | Jane Smith                              |
    And I press "Preview Message"
    And I press "Send this Alert"

    When I am on the alert log
    Then I should see an alert titled "Flying Monkey Disease"

    When I click "Update" on "Flying Monkey Disease"
    Then I should see "Create an Alert Update"
    And I should not see "Jurisdictions"
    And I should not see "Limit Roles"
    And I should not see "Organizations"
    
    When I make changes to the alert form with:
      | Message    | Flying monkey disease contagion is more widespread |
    And I press "Preview Message"
    
    Then I should see a preview of the message with:
      | Jurisdictions | Dallas County  |
      | Roles | Health Officer         |
      | Title    | [Update] - Flying Monkey Disease        |
      | Message  | Flying monkey disease contagion is more widespread |
      | Severity | Moderate            |
      | Status   | Actual              |
      | Acknowledge | No               |
      | Communication methods | E-mail |
      | Delivery Time | 72 hours       |
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alert log
    And I should see an alert titled "[Update] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Health Alert "[Update] - Flying Monkey Disease" |
      | body contains | Title: [Update] - Flying Monkey Disease |
      | body contains | Alert ID:  |
      | body contains | Reference:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | Flying monkey disease contagion is more widespread |
    And "Fix the above step to include Alert ID and Reference ID" should be implemented

  Scenario: Updating an alert as another alerter within the same jurisdiction
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert "Details" form with:
      | Title         | Flying Monkey Disease                |
      | Message       | For more details, keep on reading... |
      | Severity      | Moderate            |
      | Status        | Actual              |
      | Acknowledge   | None                |
      | Delivery Time | 72 hours            |
    And I check "E-mail"
    And I press "Select an Audience"
    And delayed jobs are processed
    And I fill out the alert "Audience" form with:
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
      | People   | Jane Smith                              |
    And I press "Preview Message"
    And I press "Send this Alert"

    When I am on the alert log
    Then I should see an alert titled "Flying Monkey Disease"

    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts
    When I am on the alert log
    Then I should see an alert titled "Flying Monkey Disease"

    When I click "Update" on "Flying Monkey Disease"
    Then I should see "Create an Alert Update"
    And I should not see "Jurisdictions"
    And I should not see "Limit Roles"
    And I should not see "Organizations"

    When I make changes to the alert form with:
      | Message    | Flying monkey disease contagion is more widespread |
    And I press "Preview Message"

    Then I should see a preview of the message with:
      | Jurisdictions | Dallas County  |
      | Roles | Health Officer         |
      | Title    | [Update] - Flying Monkey Disease        |
      | Message  | Flying monkey disease contagion is more widespread |
      | Severity | Moderate            |
      | Status   | Actual              |
      | Acknowledge | No               |
      | Communication methods | E-mail |
      | Delivery Time | 72 hours       |

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alert log
    And I should see an alert titled "[Update] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | [Update] - Flying Monkey Disease |
      | body contains | Title: [Update] - Flying Monkey Disease |
      | body contains | Alert ID:  |
      | body contains | Reference:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | Flying monkey disease contagion is more widespread |

  Scenario: Make sure re-submitting an update after alert is canceled doesn't work
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert "Details" form with:
      | Title         | Flying Monkey Disease                |
      | Message       | For more details, keep on reading... |
      | Severity      | Moderate            |
      | Status        | Actual              |
      | Acknowledge   | None                |
      | Delivery Time | 60 minutes          |
    And I check "E-mail"
    And I press "Select an Audience"
    And delayed jobs are processed
    And I fill out the alert "Audience" form with:
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
      | People   | Jane Smith                              |
    And I press "Preview Message"
    And I press "Send this Alert"

    When I go to cancel the alert
    And I make changes to the alert form with:
      | Message    | Flying monkey disease is not contagious |
    And I press "Preview Message"
    When I press "Send"
    Then I should see "Successfully sent the alert"
    When I re-submit an update for "Flying Monkey Disease"
    Then I should see "You cannot update or cancel an alert that has already been cancelled."
    And I should be on the alert log
    And I should see 2 alerts
