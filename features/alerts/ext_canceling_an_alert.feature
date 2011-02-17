@alert, @ext
Feature: Canceling an alert

  In order to keep everyone informed with up to date information
  As an alerter
  I want to be able to send out a cancel alert

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County   |
      | Role         | Health Officer  |
      | Role         | Health Alert and Communications Coordinator |
    And the following users exist:
      | John Smith      | john.smith@example.com     | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com     | Health Alert and Communications Coordinator | Dallas County |
      | Brian Simms     | brian.simms@example.com    | Health Officer                              | Dallas County |
      | Ed McGuyver     | ed.mcguyver@example.com    | Health Officer                              | Dallas County |

    And the role "Health Alert and Communications Coordinator" is an alerter

  Scenario: Canceling an alert
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And a sent alert with:
      | title                 | Flying Monkey Disease                  |
      | message               | For more details, keep on reading...   |
      | severity              | Moderate                               |
      | status                | Actual                                 |
      | acknowledge           | None                                   |
      | from_jurisdiction     | Dallas County                          |
      | communication methods | Email                                  |
      | roles                 | Health Officer                         |
      | jurisdictions         | Dallas County                          |

    When I go to the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    When I click "Cancel" within alert "Flying Monkey Disease"
    Then the "Create an Alert Cancellation" tab should be open
    And I fill in "Message" with "Flying monkey disease is not contagious"

    And I click breadCrumbItem "Preview"
    Then I should see a display form with:
      | Severity      | Moderate       |
      | Status        | Actual         |
      | Acknowledge   | No             |
      | Methods       | Email, Console |
      | Delivery Time | 72 hours       |
    And I should see "[Cancel] - Flying Monkey Disease"
    And I should see "Flying monkey disease is not contagious"

    When I expand ext panel "Alert Recipients (Primary Audience)"

    Then I should see the following audience breakdown:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |

    And I wait for the audience calculation to finish
    And I press "Send Alert"

    Then the "Alert Log and Reporting" tab should be open
    And the "Create an Alert Cancellation" tab should not be open

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
    And a sent alert with:
      | title                 | Flying Monkey Disease                  |
      | message               | For more details, keep on reading...   |
      | severity              | Moderate                               |
      | status                | Actual                                 |
      | acknowledge           | None                                   |
      | from_jurisdiction     | Dallas County                          |
      | communication methods | Email                                  |
      | roles                 | Health Officer                         |
      | jurisdictions         | Dallas County                          |

    When I sign out

    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    When I click "Cancel" within alert "Flying Monkey Disease"
    And fill in "Message" with "Flying monkey disease is not contagious"

    And I click breadCrumbItem "Preview"
    Then I should see a display form with:
      | Severity      | Moderate       |
      | Status        | Actual         |
      | Acknowledge   | No             |
      | Methods       | Email, Console |
      | Delivery Time | 72 hours       |
    And I should see "[Cancel] - Flying Monkey Disease"
    And I should see "Flying monkey disease is not contagious"

    When I expand ext panel "Alert Recipients (Primary Audience)"
    Then I should see the following audience breakdown:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |

    When I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open
    And the "Create an Alert Cancellation" tab should not be open

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
    And a sent alert with:
      | title                 | Flying Monkey Disease                  |
      | message               | For more details, keep on reading...   |
      | severity              | Moderate                               |
      | status                | Actual                                 |
      | acknowledge           | None                                   |
      | from_jurisdiction     | Dallas County                          |
      | communication methods | Email                                  |
      | roles                 | Health Officer                         |
      | jurisdictions         | Dallas County                          |

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    When I click "Cancel" within alert "Flying Monkey Disease"
    And fill in "Message" with "Flying monkey disease is not contagious"

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"

    Then I should not see button "Cancel" for alert "Flying Monkey Disease"
    When I override alert
    When I force open the alert cancellation tab
    Then I should see "You cannot update or cancel an alert that has already been cancelled." within the alert box
    Then the "Alert Log and Reporting" tab should be open
    And the "Create an Alert Update" tab should not be open
    And I should see 2 alerts
