@ext
Feature: Updating an alert
  #TODO:  make this for HAN on,y, create another feature file for custom/other
  In order to keep everyone informed with up to date information
  As an alerter
  I want to be able to send out an update to an alert

   Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County                               |
      | Jurisdiction | Potter County                               |
      | Jurisdiction | Tarrant County                              |
      | Role         | Health Officer                              |
      | Role         | Health Alert and Communications Coordinator |
    And the following users exist:
      | John Smith  | john.smith@example.com  | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith  | jane.smith@example.com  | Health Alert and Communications Coordinator | Dallas County |
      | Anne Smith  | anne.smith@example.com  | Health Alert and Communications Coordinator | Potter County |
      | Brian Simms | brian.simms@example.com | Health Officer                              | Dallas County |
      | Ed McGuyver | ed.mcguyver@example.com | Health Officer                              | Dallas County |
      | Jackie Sue  | jackie.sue@example.com  | Health Officer                              | Potter County |
      | Frank Chung | frank.chung@example.com | Health Officer                              | Potter County |
      | John Wayne  | john.wayne@example.com  | Health Officer                              | Potter County |

    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Updating an alert
    Given I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions         | Dallas County                        |
      | Roles                 | Health Officer                       |
      | Title                 | Flying Monkey Disease                |
      | Message               | For more details, keep on reading... |
      | Severity              | Moderate                             |
      | Status                | Actual                               |
      | Acknowledge           | None                                 |
      | Communication methods | E-mail                               |
      | Delivery Time         | 72 hours                             |

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should see an alert titled "Flying Monkey Disease"

    When I click "Update" within alert "Flying Monkey Disease"
    Then the "Create an Alert Update" tab should be open
    And I should not see "Jurisdictions"
    And I should not see "Limit Roles"
    And I should not see "Organizations"

    When I fill in "Message" with "Flying monkey disease contagion is more widespread"
    And I click breadCrumbItem "Preview"

    Then I should see a display form with:
      | Severity      | Moderate       |
      | Status        | Actual         |
      | Acknowledge   | No             |
      | Methods       | Email, Console |
      | Delivery Time | 72 hours       |
    And I should see "[Update] - Flying Monkey Disease"
    And I should see "Flying monkey disease contagion is more widespread"

    When I expand ext panel "Audience"
    Then I should see the following audience breakdown:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |

    When I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open
    And the "Send Alert" tab should not be open
    And I should see an alert titled "[Update] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com   |
      | subject       | Health Alert "[Update] - Flying Monkey Disease"    |
      | body contains | Title: [Update] - Flying Monkey Disease            |
      | body contains | Alert ID:                                          |
      | body contains | Reference:                                         |
      | body contains | Agency: Dallas County                              |
      | body contains | Sender: John Smith                                 |
      | body contains | Flying monkey disease contagion is more widespread |
    And "Fix the above step to include Alert ID and Reference ID" should be implemented

  Scenario: Updating an alert as another alerter within the same jurisdiction
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I've sent an alert with:
      | Jurisdictions         | Dallas County                        |
      | Roles                 | Health Officer                       |
      | Title                 | Flying Monkey Disease                |
      | Message               | For more details, keep on reading... |
      | Severity              | Moderate                             |
      | Status                | Actual                               |
      | Acknowledge           | None                                 |
      | Communication methods | E-mail                               |
      | Delivery Time         | 72 hours                             |

    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    And I click "Update" within alert "Flying Monkey Disease"
    Then the "Create an Alert Update" tab should be open
    And I should not see "Jurisdictions"
    And I should not see "Limit Roles"
    And I should not see "Organizations"

    When I fill in "Message" with "Flying monkey disease contagion is more widespread"
    And I click breadCrumbItem "Preview"
    Then I should see a display form with:
      | Severity      | Moderate       |
      | Status        | Actual         |
      | Acknowledge   | No             |
      | Methods       | Email, Console |
      | Delivery Time | 72 hours       |
    And I should see "[Update] - Flying Monkey Disease"
    And I should see "Flying monkey disease contagion is more widespread"

    When I expand ext panel "Audience"
    Then I should see the following audience breakdown:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |

    When I press "Send Alert"
    Then I should see an alert titled "[Update] - Flying Monkey Disease"
    And the following users should receive the alert email:
      | People        | brian.simms@example.com, ed.mcguyver@example.com   |
      | subject       | [Update] - Flying Monkey Disease                   |
      | body contains | Title: [Update] - Flying Monkey Disease            |
      | body contains | Alert ID:                                          |
      | body contains | Reference:                                         |
      | body contains | Agency: Dallas County                              |
      | body contains | Sender: John Smith                                 |
      | body contains | Flying monkey disease contagion is more widespread |

  Scenario: Updating an alert that used Advanced Acknowledgement
    Given I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions         | Potter County                                |
      | Jurisdiction          | Dallas County                                |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | Some body text                               |
      | Severity              | Minor                                        |
      | Status                | Actual                                       |
      | Acknowledge           | Advanced                                     |
      | Communication methods | E-mail                                       |
      | Delivery Time         | 72 hours                                     |
      | Alert Response 1      | if you can respond within 15 minutes         |
      | Alert Response 2      | if you can respond within 30 minutes         |
      | Alert Response 3      | if you can respond within 1 hour             |
      | Alert Response 4      | if you can respond within 4 hours            |
      | Alert Response 5      | if you cannot respond                        |
    And delayed jobs are processed
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    And I click "Update" within alert "H1N1 SNS push packs to be delivered tomorrow"
    Then I should see "[Update] - H1N1 SNS push packs to be delivered tomorrow"
    And I should not see "Alert Response 1"

    When I open ext combo "Acknowledgement"
    Then I should not see "Advanced" within ".x-combo-list"

    When I fill in "Message" with "Update to message"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"
    And I press "Next"
    And I press "Send Alert"
    Then an alert exists with:
      | from_jurisdiction  | Dallas County                                           |
      | title              | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message            | Update to message                                       |
      | call_down_messages | if you can respond within 15 minutes                    |
      | call_down_messages | if you can respond within 30 minutes                    |
      | call_down_messages | if you can respond within 1 hour                        |
      | call_down_messages | if you can respond within 4 hours                       |
      | call_down_messages | if you cannot respond                                   |

  Scenario:Updating an alert that used Advanced Acknowledgement and removing response options
    Given I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions         | Potter County                                |
      | Jurisdiction          | Dallas County                                |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | Some body text                               |
      | Severity              | Minor                                        |
      | Status                | Actual                                       |
      | Acknowledge           | Advanced                                     |
      | Communication methods | E-mail                                       |
      | Delivery Time         | 90 minutes                                   |
      | Alert Response 1      | if you can respond within 15 minutes         |
      | Alert Response 2      | if you can respond within 30 minutes         |
      | Alert Response 3      | if you can respond within 1 hour             |
      | Alert Response 4      | if you can respond within 4 hours            |
      | Alert Response 5      | if you cannot respond                        |
    And delayed jobs are processed
    And "john.wayne@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes" 30 minutes later
    And "jane.smith@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 30 minutes" 30 minutes later

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    And I click "Update" within alert "H1N1 SNS push packs to be delivered tomorrow"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs to be delivered in 15 minutes at point A"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"
    And I check "if you can respond within 15 minutes"
    And I uncheck "if you can respond within 30 minutes"
    And I uncheck "if you can respond within 1 hour"
    And I uncheck "if you can respond within 4 hours"
    And I uncheck "if you cannot respond"

    And I send the alert

    And I click "Update" within alert "H1N1 SNS push packs to be delivered tomorrow"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs to be delivered in 30 minutes at point B"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"
    And I select "Normal" from ext combo "Acknowledge"
    And I uncheck "if you can respond within 15 minutes"
    And I check "if you can respond within 30 minutes"
    And I uncheck "if you can respond within 1 hour"
    And I uncheck "if you can respond within 4 hours"
    And I uncheck "if you cannot respond"

    And I send the alert

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                                |
      | title               | [Update] - H1N1 SNS push packs to be delivered tomorrow      |
      | message             | H1N1 SNS push packs to be delivered in 15 minutes at point A |
      | targets             | john.wayne@example.com                                       |
      | call_down_messages  | if you can respond within 15 minutes                         |
      | acknowledge         | false                                                        |
    Then an alert should not exist with:
      | title   | [Update] - H1N1 SNS push packs to be delivered tomorrow                                      |
      | message | H1N1 SNS push packs to be delivered in 15 minutes at point A                                 |
      | targets | john.smith@example.com,jane.smith@example.com,jackie.sue@example.com,frank.chung@example.com |

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                                |
      | title               | [Update] - H1N1 SNS push packs to be delivered tomorrow      |
      | message             | H1N1 SNS push packs to be delivered in 30 minutes at point B |
      | targets             | jane.smith@example.com                                       |
      | call_down_messages  | if you can respond within 30 minutes                         |
      | acknowledge         | true                                                         |
    Then an alert should not exist with:
      | title   | [Update] - H1N1 SNS push packs to be delivered tomorrow                                      |
      | message | H1N1 SNS push packs to be delivered in 30 minutes at point B                                 |
      | targets | john.smith@example.com,john.wayne@example.com,jackie.sue@example.com,frank.chung@example.com |

  Scenario: Make sure re-submitting an update after alert is canceled doesn't work
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I've sent an alert with:
      | Jurisdictions         | Dallas County                        |
      | Roles                 | Health Officer                       |
      | Title                 | Flying Monkey Disease                |
      | Message               | For more details, keep on reading... |
      | Severity              | Moderate                             |
      | Status                | Actual                               |
      | Acknowledge           | None                                 |
      | Communication methods | E-mail                               |
      | Delivery Time         | 60 minutes                           |

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    When I click "Cancel" within alert "Flying Monkey Disease"
    And fill in "Message" with "Flying monkey disease is not contagious"

    And I send the alert

    Then I should not see button "Update" for alert "Flying Monkey Disease"
    When I override alert
    When I force open the tab "Create an Alert Update" for "" with config "{title: 'Create an Alert Update', url: 'alerts/1/edit?_action=update', mode: 'update', initializer: 'Talho.SendAlert', alertId: 1}"
    Then I should see "You cannot update or cancel an alert that has already been cancelled." within the alert box
    Then the "Alert Log and Reporting" tab should be open
    And the "Create an Alert Update" tab should not be open
    And I should see 2 alerts
