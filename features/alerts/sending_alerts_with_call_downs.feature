Feature: Sending alerts with call downs

  In order to send an alert with call down options specified
  As an alerter
  Users should receive alerts with call down response options
  
  
  Scenario: Sending alert updates with call down
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions   | Potter County       |
      | Jurisdiction    | Dallas County                                |
      | Title           | H1N1 SNS push packs to be delivered tomorrow |
      | Message         | Some body text      |
      | Severity        | Minor               |
      | Status          | Actual              |
      | Acknowledge     | Advanced            |
      | Communication methods | E-mail        |
      | Delivery Time    | 72 hours           |
      | Alert Response 1 | if you can respond within 15 minutes |
      | Alert Response 2 | if you can respond within 30 minutes |
      | Alert Response 3 | if you can respond within 1 hour     |
      | Alert Response 4 | if you can respond within 4 hours    |
      | Alert Response 5 | if you cannot respond                |
      
    When I go to the HAN
    And I follow "Alert Log and Reporting"
    And I follow "Update"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    And I should not see "Alert Response 1"
    And I should not see "Advanced"
    When I fill in "Message" with "Update to message"
    And I select "Minor" from "Severity"
    And I select "72 hours" from "Delivery Time"
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                |
      | title               | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message             | Update to message                            |
      | call_down_messages  | if you can respond within 15 minutes         |
      | call_down_messages  | if you can respond within 30 minutes         |
      | call_down_messages  | if you can respond within 1 hour             |
      | call_down_messages  | if you can respond within 4 hours            |
      | call_down_messages  | if you cannot respond                        |

  Scenario: Sending alert updates with call down and responses
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer  | Potter County |
      | Jackie Sue      | jackie.sue@example.com   | Health Officer  | Potter County |
      | Frank Chung     | frank.chung@example.com  | Health Officer  | Potter County |
      | John Wayne      | john.wayne@example.com   | Health Officer  | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions    | Potter County       |
      | Jurisdiction     | Dallas County       |
      | Title            | H1N1 SNS push packs to be delivered tomorrow |
      | Message          | Some body text      |
      | Severity         | Minor               |
      | Status           | Actual              |
      | Acknowledge      | Advanced            |
      | Communication methods | E-mail         |
      | Delivery Time    | 90 minutes          |
      | Alert Response 1 | if you can respond within 15 minutes |
      | Alert Response 2 | if you can respond within 30 minutes |
      | Alert Response 3 | if you can respond within 1 hour     |
      | Alert Response 4 | if you can respond within 4 hours    |
      | Alert Response 5 | if you cannot respond                |
    And delayed jobs are processed
    And "john.wayne@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes" 30 minutes later
    And "jane.smith@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 30 minutes" 30 minutes later

    When I go to the HAN
    And I follow "Alert Log and Reporting"
    And I follow "Update"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs to be delivered in 15 minutes at point A"
    And I select "Minor" from "Severity"
    And I select "72 hours" from "Delivery Time"
    And I select "if you can respond within 15 minutes" from "Responders"
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    When I go to the HAN
    And I follow "Alert Log and Reporting"
    And I follow "Update"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs to be delivered in 30 minutes at point B"
    And I select "Minor" from "Severity"
    And I select "72 hours" from "Delivery Time"
    And I select "Normal" from "Acknowledge"
    And I select "if you can respond within 30 minutes" from "Responders"
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                |
      | title               | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message             | H1N1 SNS push packs to be delivered in 15 minutes at point A |
      | targets             | john.wayne@example.com  |
      | call_down_messages  | if you can respond within 15 minutes         |
      | acknowledge         | false                                         |
    Then an alert should not exist with:
      | title   | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message | H1N1 SNS push packs to be delivered in 15 minutes at point A |
      | targets | john.smith@example.com,jane.smith@example.com,jackie.sue@example.com,frank.chung@example.com |

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                |
      | title               | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message             | H1N1 SNS push packs to be delivered in 30 minutes at point B |
      | targets             | jane.smith@example.com  |
      | call_down_messages  | if you can respond within 30 minutes         |
      | acknowledge         | true                                         |
    Then an alert should not exist with:
      | title   | [Update] - H1N1 SNS push packs to be delivered tomorrow |
      | message | H1N1 SNS push packs to be delivered in 30 minutes at point B |
      | targets | john.smith@example.com,john.wayne@example.com,jackie.sue@example.com,frank.chung@example.com |

  Scenario: Sending alert cancellation with call down and responses
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer  | Potter County |
      | Jackie Sue      | jackie.sue@example.com   | Health Officer  | Potter County |
      | Frank Chung     | frank.chung@example.com  | Health Officer  | Potter County |
      | John Wayne      | john.wayne@example.com   | Health Officer  | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I've sent an alert with:
      | Jurisdictions    | Potter County       |
      | Jurisdiction     | Dallas County       |
      | Title            | H1N1 SNS push packs to be delivered tomorrow |
      | Message          | Some body text      |
      | Severity         | Minor               |
      | Status           | Actual              |
      | Acknowledge      | Advanced            |
      | Communication methods | E-mail         |
      | Delivery Time    | 90 minutes          |
      | Alert Response 1 | if you can respond within 15 minutes |
      | Alert Response 2 | if you can respond within 30 minutes |
      | Alert Response 3 | if you can respond within 1 hour     |
      | Alert Response 4 | if you can respond within 4 hours    |
      | Alert Response 5 | if you cannot respond                |
    And delayed jobs are processed
    And "john.wayne@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes" 30 minutes later
    And "jane.smith@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 30 minutes" 30 minutes later

    When I go to the HAN
    And I follow "Alert Log and Reporting"
    And I follow "Cancel"

    Then I should see "H1N1 SNS push packs to be delivered tomorrow"
    When I fill in "Message" with "H1N1 SNS push packs all deployed"
    And I select "Minor" from "Severity"
    And I select "72 hours" from "Delivery Time"
    And I select "Normal" from "Acknowledge"
    And I select "if you can respond within 15 minutes" from "Responders"
    And I select "if you can respond within 30 minutes" from "Responders"
    And I select "if you can respond within 1 hour" from "Responders"
    And I select "if you can respond within 4 hours" from "Responders"
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    Then an alert exists with:
      | from_jurisdiction   | Dallas County                                |
      | title               | [Cancel] - H1N1 SNS push packs to be delivered tomorrow |
      | message             | H1N1 SNS push packs all deployed |
      | targets             | john.wayne@example.com,jane.smith@example.com  |
      | call_down_messages  | if you can respond within 15 minutes         |
      | call_down_messages  | if you can respond within 30 minutes         |
      | call_down_messages  | if you can respond within 1 hour             |
      | call_down_messages  | if you can respond within 4 hours            |
      | acknowledge         | true                                         |
    Then an alert should not exist with:
      | title   | [Cancel] - H1N1 SNS push packs to be delivered tomorrow |
      | message | H1N1 SNS push packs all deployed |
      | targets | john.smith@example,jackie.sue@example.com,frank.chung@example.com |
  
    Scenario: Reviewing Alert Log for Alert with Alert Responses
      Given the following entities exists:
        | Jurisdiction | Dallas County  |
        | Jurisdiction | Potter County  |
        | Jurisdiction | Tarrant County |
      And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer  | Potter County |
      | Jackie Sue      | jackie.sue@example.com   | Health Officer  | Potter County |
      | Frank Chung     | frank.chung@example.com  | Health Officer  | Potter County |
      | John Wayne      | john.wayne@example.com   | Health Officer  | Potter County |
     And the role "HAN Coordinator" is an alerter
      And I am logged in as "john.smith@example.com"
      And I've sent an alert with:
        | Jurisdictions   | Potter County       |
        | Jurisdiction    | Dallas County                                |
        | Title           | H1N1 SNS push packs to be delivered tomorrow |
        | Message         | Some body text      |
        | Severity        | Minor               |
        | Status          | Actual              |
        | Acknowledge     | Advanced            |
        | Communication methods | E-mail        |
        | Delivery Time    | 72 hours           |
        | Alert Response 1 | if you can respond within 15 minutes |
        | Alert Response 2 | if you can respond within 30 minutes |
        | Alert Response 3 | if you can respond within 1 hour     |
        | Alert Response 4 | if you can respond within 4 hours    |
        | Alert Response 5 | if you cannot respond                |
      And delayed jobs are processed  

      And "john.wayne@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes" 30 minutes later
      And "jane.smith@example.com" has acknowledged the alert "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 30 minutes" 30 minutes later

      When I go to the HAN
      And I follow "Alert Log and Reporting"
      And I should see "Acknowledge: Advanced"
      And I can see the alert acknowledgement response rate for "H1N1 SNS push packs to be delivered tomorrow" in "if you can respond within 15 minutes" is 25%