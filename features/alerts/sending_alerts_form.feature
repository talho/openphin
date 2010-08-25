Feature: Sending alerts form

  In order to ensure only accessible information is displayed on the form
  As an admin
  Users should not be able to see certain information on the form
  
  Scenario: Sending alerts form should not contain system roles
    Given there is an system only Admin role
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | Hello World          |
      | Message               | Hello World          |
      | Short Message         | Hello World          |
      | Acknowledge           | Normal               |
      | Communication methods | E-mail               |
    Then I should explicitly not see the "Admin" role as an option

  Scenario: User with one or more jurisdictions
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the HAN
    And I follow "Send an Alert"

    Then I should see "Dallas County" as a from jurisdiction option
    Then I should see "Potter County" as a from jurisdiction option
    Then I should not see "Tarrant County" as a from jurisdiction option

    And I fill out the alert form with:
      | Jurisdiction          | Potter County                            |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | H1N1 SNS push packs to be delivered tomorrow         |
      | Short Message         | H1N1 SNS push packs to be delivered tomorrow         |
      | Communication methods | E-mail               |
      | Jurisdictions | Potter County |
    And I press "Preview Message"

    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    When delayed jobs are processed
    Then an alert exists with:
      | from_jurisdiction | Potter County |
      | title | H1N1 SNS push packs to be delivered tomorrow |

  Scenario: Send an alert with a different delivery time
    Given the following entities exists:
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County  |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the HAN
    And I follow "Send an Alert"
    Then I should see "Potter County" as a from jurisdiction option
    Then I should not see "Tarrant County" as a from jurisdiction option
    When I fill out the alert form with:
      | Jurisdiction | Potter County                            |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Delivery Time | 60 minutes |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | Delivery Time | 60 minutes |
    When I press "Send"
    Then I should see "Successfully sent the alert"
    When delayed jobs are processed
    Then an alert exists with:
      | from_jurisdiction | Potter County |
      | title | H1N1 SNS push packs to be delivered tomorrow |
      | delivery_time | 60 |    

  Scenario: Sending alerts should display Federal jurisdiction as an option
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | Fake Title |
      | Message               | Fake Message         |
      | Short Message         | Fake Short Message        |
      | Communication methods | E-mail               |
    Then I should see "Federal" as a jurisdictions option

  Scenario: Sending alerts should show "Select all children" link for parent jurisdictions
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am on the new alert page
    Then I should see "Select all children"

  Scenario: Sending alerts with only People in the audience should work
    Given the following entities exist:
      | Jurisdiction | Texas         |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator  | Texas |
      | Jane Smith      | jane.smith@example.com   | HAN Coordinator  | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And delayed jobs are processed
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow         |
      | Message               | H1N1 SNS push packs to be delivered tomorrow          |
      | Short Message         | H1N1 SNS push packs to be delivered tomorrow          |
      | Communication methods | E-mail          |
      | People         | Jane Smith     |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | People            | Jane Smith |
      
    And I press "Send"
    Then an alert exists with:
      | from_jurisdiction | Texas                                        |
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |

  Scenario: Sending alerts with call down
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the HAN
    And I follow "Send an Alert"

    When I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"

    And I fill in "Message" with "Some body text"
    And I select "Advanced" from "Acknowledge"
    And I fill in "Alert Response 1" with "if you can respond within 15 minutes"
    And I fill in "Alert Response 2" with "if you can respond within 30 minutes"
    And I fill in "Alert Response 3" with "if you can respond within 1 hour"
    And I fill in "Alert Response 4" with "if you can respond within 4 hour"
    And I fill in "Alert Response 5" with "if you cannot respond"
    And I select "Potter County" from "Jurisdiction"
    And I select "Test" from "Status"
    And I select "Minor" from "Severity"
    And I select "72 hours" from "Delivery time"
    And I check "Phone"

    And I press "Audience"
    And I check "Potter County"

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    Then an alert exists with:
      | from_jurisdiction   | Potter County                                |
      | title               | H1N1 SNS push packs to be delivered tomorrow |
      | call_down_messages  | if you can respond within 15 minutes         |
      | call_down_messages  | if you can respond within 30 minutes         |
      | call_down_messages  | if you can respond within 1 hour             |
      | call_down_messages  | if you can respond within 4 hours            |
      | call_down_messages  | if you cannot respond                        |
      | acknowledge         | true                                         |


  Scenario: Sending alerts with non cross jurisdiction
     Given the following entities exists:
       | Jurisdiction | Dallas County  |
       | Jurisdiction | Potter County  |
       | Jurisdiction | Tarrant County |
     And the following users exist:
       | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
       | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
     And the role "HAN Coordinator" is an alerter
     And I am logged in as "john.smith@example.com"

     When I go to the HAN
     And I follow "Send an Alert"

     When I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"

     And I fill in "Message" with "Some body text"
     And I will confirm on next step
     And I check "Disable Cross-Jurisdictional alerting"
     And I select "Potter County" from "Jurisdiction"
     And I select "Test" from "Status"
     And I select "Minor" from "Severity"
     And I select "72 hours" from "Delivery time"
     And I select "Normal" from "Acknowledge"
     And I check "Phone"
     And I press "Audience"
     And I check "Potter County"
     And I press "Preview Message"
     Then I should see a preview of the message

     When I press "Send"
     Then I should see "Successfully sent the alert"

     Then an alert exists with:
      | from_jurisdiction         | Potter County                                |
      | title                     | H1N1 SNS push packs to be delivered tomorrow |
      | not_cross_jurisdictional  | true                                         |


  Scenario: Sending alerts to Organizations
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Organization | DSHS          |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator  | Texas |
      | Jane Smith      | jane.smith@example.com   | Health Officer   | Texas |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow         |
      | Message               | H1N1 SNS push packs to be delivered tomorrow         |
      | Short Message         | H1N1 SNS push packs to be delivered tomorrow         |
      | Communication methods | E-mail          |
      | Organization   | DSHS      |

    And I press "Preview Message"
    Then I should see a preview of the message with:
      | Organization  | DSHS |
      
    And I press "Send"
    Then an alert exists with:
      | from_jurisdiction | Texas                                        |
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |