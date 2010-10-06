@ext
Feature: Viewing the alert log
  Background:
    Given the following entities exists:
      | Role | Health Alert and Communications Coordinator |
    And the role "Health Alert and Communications Coordinator" is an alerter

  Scenario: Viewing list of alerts in your jurisdictions
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
      | jurisdictions     | Dallas County |
      | acknowledge       | No            |
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should see an alert titled "Hello World"
    And I should see "Acknowledge: None"

    When I click "View" within alert "Hello World"
    And I wait for the "Loading" mask to go away
    Then I can see the alert summary for "Hello World"
    And I should see "None" within display field "Acknowledge"

  Scenario: Viewing list of alerts sent directly to you
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
    And I am logged in as "john.smith@example.com"
    And a sent alert with:
      | from_jurisdiction | Dallas County |
      | people            | John Smith    |
      | title             | Hello World   |
      | acknowledge       | No            |
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should see an alert titled "Hello World"
    And I should see "Acknowledge: None"

    When I click "View" within alert "Hello World"
    And I wait for the "Loading" mask to go away
    Then I can see the alert summary for "Hello World"
    And I should see "None" within display field "Acknowledge"

  Scenario: Viewing list of alerts in child jurisdictions
    Given the following entities exists:
      | Jurisdiction | Texas                                    |
      | Jurisdiction | Dallas County                            |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
      | jurisdictions     | Dallas County |
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should see an alert titled "Hello World"

    When I click "View" within alert "Hello World"
    Then I should see "Hello World"

  Scenario: Can't view alerts from outside jurisdictions
    Given the following entities exists:
      | Jurisdiction | Potter County |
      | Jurisdiction | Dallas County |
    And the following users exist:
      | John Smith | john.smith@example.com | Health Alert and Communications Coordinator | Dallas County |
    And the following users exist:
      | Sam Body | sam@example.com | Health Alert and Communications Coordinator | Dallas County |
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | author            | Sam Body      |
      | from_jurisdiction | Potter County |
      | title             | Hello World   |
      | jurisdiction      | Potter County |
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should not see an alert titled "Hello World"

  Scenario: View alert log by alert type

  Scenario: Viewing percentage of recipients that have acknowledged
    Given the following entities exists:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Jane Smith      | jane.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | Health Alert and Communications Coordinator | Texas |
    And a sent alert with:
      | from_jurisdiction     | Texas                                       |
      | title                 | Hello World                                 |
      | message               | Hello World                                 |
      | short_message         | Hello World                                 |
      | acknowledge           | Yes                                         |
      | audiences             |                                             |
      | communication methods | Email, SMS                                  |
      | caller_id             | 1234567890                                  |
      | roles                 | Health Alert and Communications Coordinator |
      | jurisdictions         | Texas, Dallas County                        |
    And delayed jobs are processed

    And I am logged in as "jane.smith@example.com"
    When I am on the ext dashboard page
    And I navigate to "HAN > HAN Home"
    And I click "More" within alert "Hello World"
    And I press "Acknowledge"
    And I wait for the "Saving" mask to go away
    And I sign out

    And I am logged in as "john.smith@example.com"
    And delayed jobs are processed
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    And I click "More" within alert "Hello World"
    And I can see the alert for "Hello World" is 33% acknowledged
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Texas" is 33%
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Dallas County" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "E-mail" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "Console" is 33%
    And I can see the device alert acknowledgement rate for "Hello World" in "SMS" is 0%
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Phone"
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Fax"
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Blackberry"
    And I navigate to "HAN > HAN Home"
    And I click "More" within alert "Hello World"
    And I press "Acknowledge"
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    And I click "More" within alert "Hello World"
    And I should see "Acknowledge: Normal"
    And I can see the alert for "Hello World" is 67% acknowledged
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Texas" is 67%
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Dallas County" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "E-mail" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "Console" is 67%
    And I can see the device alert acknowledgement rate for "Hello World" in "SMS" is 0%

  Scenario: Viewing a really large alert log
    Given the following entities exist:
      | Jurisdiction | Texas |
      | Jurisdiction | R1 |
      | Jurisdiction | R2 |
      | Jurisdiction | C1 |
      | Jurisdiction | C2 |
    And Texas is the parent jurisdiction of:
      | R1|R2 |
    And R1 is the parent jurisdiction of:
      | C1|C2 |
    And 15 jurisdictions that are children of R1
    And 150 jurisdictions that are children of R2
    And 20 random alerts in R1
    And 20 random alerts in R2
    And 10 random alerts in C1
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | R1 |
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | C1 |
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | R2 |
    And "john.smith@example.com" is not public in "Texas"
    And I am logged in as "john.smith@example.com"
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I should see 10 alerts

  Scenario: Viewing acknowledged alerts with alert responses
    Given the following entities exists:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Jane Smith      | jane.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | Health Alert and Communications Coordinator | Texas |
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction     | Texas                                       |
      | jurisdictions         | Texas, Dallas County                        |
      | roles                 | Health Alert and Communications Coordinator |
      | audiences             |                                             |
      | title                 | Hello World                                 |
      | communication methods | Email                                       |
      | alert_response_1      | if you can respond within 15 minutes        |
      | alert_response_2      | if you can respond within 30 minutes        |
      | alert_response_3      | if you can respond within 1 hour            |
      | alert_response_4      | if you can respond within 4 hours           |
      | alert_response_5      | if you cannot respond                       |
    And "jane.smith@example.com" has acknowledged the alert "Hello World"
    And "john.smith@example.com" has not acknowledged the alert "Hello World"
    And "daniel@example.com" has not acknowledged the alert "Hello World"
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    And I should see "Acknowledge: Advanced"
    When I click "More" within alert "Hello World" 
    And I navigate to "HAN > HAN Home"
    And I click "More" within alert "Hello World"
    And I should see "Alert Response"

  Scenario: Viewing acknowledged advanced alerts with alert responses from view
    Given the following entities exists:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Jane Smith      | jane.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | Health Alert and Communications Coordinator | Texas |
    And I am logged in as "john.smith@example.com"
    And a sent alert with:
      | from_jurisdiction     | Texas                                       |
      | jurisdictions         | Texas, Dallas County                        |
      | roles                 | Health Alert and Communications Coordinator |
      | title                 | Hello World                                 |
      | communication methods | Email                                       |
      | alert_response_1      | if you can respond within 15 minutes        |
      | alert_response_2      | if you can respond within 30 minutes        |
      | alert_response_3      | if you can respond within 1 hour            |
      | alert_response_4      | if you can respond within 4 hours           |
      | alert_response_5      | if you cannot respond                       |
    And "jane.smith@example.com" has acknowledged the alert "Hello World"
    And "john.smith@example.com" has not acknowledged the alert "Hello World"
    And "daniel@example.com" has not acknowledged the alert "Hello World"
    When I am on the ext dashboard page
    And I navigate to "HAN > HAN Home"
    Then I should see "Alert Response"
    When I click "More" within alert "Hello World"
    And I select "if you can respond within 15 minutes" from "Alert Response"
    And I press "Acknowledge"
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    When I click "View" within alert "Hello World"
    And I wait for the "Loading" mask to go away
    Then I should see "if you can respond within 15 minutes"

  Scenario: Viewing audience of Alert and advanced acknowledgement log from view(show)
    Given the following entities exists:
      | Jurisdiction | Texas          |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Jane Smith      | jane.smith@example.com   | Health Alert and Communications Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | Health Alert and Communications Coordinator | Texas |
    And I am logged in as "john.smith@example.com"
    And a sent alert with:
      | from_jurisdiction     | Texas                                |
      | jurisdictions         | Texas                                |
      | roles                 | Health Alert and Communications Coordinator |
      | title                 | Hello World                          |
      | message               | Hello World                          |
      | short_message         | Hello World                          |
      | acknowledge           | Yes                                  |
      | communication methods | Email, Console                       |
      | alert_response_1      | if you can respond within 15 minutes |
      | alert_response_2      | if you can respond within 30 minutes |
      | alert_response_3      | if you can respond within 1 hour     |
      | alert_response_4      | if you can respond within 4 hours    |
      | alert_response_5      | if you cannot respond                |
    And "jane.smith@example.com" has acknowledged the alert "Hello World" with "" 0 minutes later
    And "daniel@example.com" has acknowledged the alert "Hello World" with "if you cannot respond" 0 minutes later
    And I follow the acknowledge alert link
    And delayed jobs are processed
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    When I click "View" within alert "Hello World"
    And I wait for the "Loading" mask to go away

    Then I should see "John Smith" within display field "Author"
    And I should see "Created at:"
    And I expand ext panel "Audience"
    Then I should see the following audience breakdown:
      | name                                        | type         |
      | Texas                                       | Jurisdiction |
      | Health Alert and Communications Coordinator | Role         |
    And I should see "John Smith" for user "John Smith"
    And I should see "if you cannot respond" for user "Daniel Morrison"

  Scenario: Viewing audience of Alert and regular acknowledgement log from view(show)
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Organization | DSHS          |
    And the following users exist:
      | John Smith   | john.smith@example.com | Health Alert and Communications Coordinator  | Texas |
      | Jane Smith   | jane.smith@example.com | Health Officer                               | Texas |
      | Daniel Smith | daniel@example.com     | Health Officer                               | Texas |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And a sent alert with:
      | from_jurisdiction     | Texas          |
      | jurisdictions         | Texas          |
      | roles                 | Health Officer |
      | people                | John Smith     |
      | title                 | Hello World    |
      | communication methods | Email          |
      | acknowledge           | Yes            |
    And I sign out
    And delayed jobs are processed

    When I am logged in as "daniel@example.com"
    And I follow the acknowledge alert link
    And I sign out
    And delayed jobs are processed

    When I am logged in as "john.smith@example.com"
    When I am on the ext dashboard page
    And I navigate to "HAN > Alert Log and Reporting"
    Then I can see the alert summary for "Hello World"
    When I click "View" within alert "Hello World"
    And I wait for the "Loading" mask to go away

    Then I should see "John Smith" within display field "Author"
    And I should see "Created at:"
    #      And I should see /\d\d:\d\d/ within ".created_at"
    And I expand ext panel "Audience"
    Then I should see the following audience breakdown:
      | name           | type         |
      | Texas          | Jurisdiction |
      | Health Officer | Role         |
      | John Smith     | User         |
    And I should see "Acknowledged" for user "Daniel Smith"