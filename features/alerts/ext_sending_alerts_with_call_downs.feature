@ext
Feature: Sending alerts with call downs

  In order to send an alert with call down options specified
  As an alerter
  Users should receive alerts with call down response options

  Background:
    Given the following entities exists:
      | Role | Health Alert and Communications Coordinator |
    And the role "Health Alert and Communications Coordinator" is an alerter

  Scenario: Sending alert updates with call down
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith | john.smith@example.com | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith | jane.smith@example.com | Health Alert and Communications Coordinator | Potter County |
    And I am logged in as "john.smith@example.com"
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

    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    When I click "Update" within alert "H1N1 SNS push packs to be delivered tomorrow"

    Then I should see "[Update] - H1N1 SNS push packs to be delivered tomorrow"
    And I should not see "Alert Response 1"
    When I open ext combo "Acknowledgement"
    Then I should not see "Advanced" within ".x-combo-list"
    When I fill in "Message" with "Update to message"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"

    And I send the alert

    Then an alert exists with:
      | from_jurisdiction  | Dallas County                                           |
      | title              | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message            | Update to message                                       |
      | call_down_messages | if you can respond within 15 minutes                    |
      | call_down_messages | if you can respond within 30 minutes                    |
      | call_down_messages | if you can respond within 1 hour                        |
      | call_down_messages | if you can respond within 4 hours                       |
      | call_down_messages | if you cannot respond                                   |

  Scenario: Sending alert updates with call down and responses
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith  | john.smith@example.com  | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith  | jane.smith@example.com  | Health Officer                              | Potter County |
      | Jackie Sue  | jackie.sue@example.com  | Health Officer                              | Potter County |
      | Frank Chung | frank.chung@example.com | Health Officer                              | Potter County |
      | John Wayne  | john.wayne@example.com  | Health Officer                              | Potter County |
    And I am logged in as "john.smith@example.com"
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

  Scenario: Sending alert cancellation with call down and responses
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith  | john.smith@example.com  | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith  | jane.smith@example.com  | Health Officer                              | Potter County |
      | Jackie Sue  | jackie.sue@example.com  | Health Officer                              | Potter County |
      | Frank Chung | frank.chung@example.com | Health Officer                              | Potter County |
      | John Wayne  | john.wayne@example.com  | Health Officer                              | Potter County |
    And I am logged in as "john.smith@example.com"
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
    And I click "Cancel" within alert "H1N1 SNS push packs to be delivered tomorrow"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs all deployed"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"
    And I select "Normal" from ext combo "Acknowledge"
    And I check "if you can respond within 15 minutes"
    And I check "if you can respond within 30 minutes"
    And I check "if you can respond within 1 hour"
    And I check "if you can respond within 4 hours"
    And I uncheck "if you cannot respond"

    And I send the alert

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                           |
      | title               | [Cancel] - H1N1 SNS push packs to be delivered tomorrow |
      | message             | H1N1 SNS push packs all deployed                        |
      | targets             | john.wayne@example.com,jane.smith@example.com           |
      | call_down_messages  | if you can respond within 15 minutes                    |
      | call_down_messages  | if you can respond within 30 minutes                    |
      | call_down_messages  | if you can respond within 1 hour                        |
      | call_down_messages  | if you can respond within 4 hours                       |
      | acknowledge         | true                                                    |
    Then an alert should not exist with:
      | title   | [Cancel] - H1N1 SNS push packs to be delivered tomorrow           |
      | message | H1N1 SNS push packs all deployed                                  |
      | targets | john.smith@example,jackie.sue@example.com,frank.chung@example.com |

    Scenario: Reviewing Alert Log for Alert with Alert Responses
      Given the following entities exists:
        | Jurisdiction | Dallas County  |
        | Jurisdiction | Potter County  |
        | Jurisdiction | Tarrant County |
      And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer                              | Potter County |
      | Jackie Sue      | jackie.sue@example.com   | Health Officer                              | Potter County |
      | Frank Chung     | frank.chung@example.com  | Health Officer                              | Potter County |
      | John Wayne      | john.wayne@example.com   | Health Officer                              | Potter County |
      And I am logged in as "john.smith@example.com"
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

      And "john.wayne@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes" 30 minutes later
      And "jane.smith@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 30 minutes" 30 minutes later

      When I am on the ext dashboard page
      And I navigate to "HAN > Alert Log and Reporting"
      And I should see "Acknowledge: Advanced"
      And I click "More" within alert "H1N1 SNS push packs to be delivered tomorrow"
      And I can see the alert acknowledgement response rate for "H1N1 SNS push packs to be delivered tomorrow" in "if you can respond within 15 minutes" is 20%