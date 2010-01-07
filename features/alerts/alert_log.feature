Feature: Viewing the alert log

  Scenario: Viewing list of alerts in your jurisdictions
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
      | jurisdictions     | Dallas County |
    When I am on the alert log
    Then I should see an alert titled "Hello World"

    When I click "View" on "Hello World"
    Then I can see the alert summary for "Hello World"

  Scenario: Viewing list of alerts sent directly to you
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And a sent alert with:
      | people | John Smith |
      | title             | Hello World   |
    When I am on the alert log
    Then I should see an alert titled "Hello World"

    When I click "View" on "Hello World"
    Then I can see the alert summary for "Hello World"

  Scenario: Viewing list of alerts in child jurisdictions
    Given the following entities exists:
      | Jurisdiction | Texas                                    |
      | Jurisdiction | Dallas County                            |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Texas |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
      | jurisdictions     | Dallas County |
    When I am on the alert log
    Then I should see an alert titled "Hello World"

    When I follow "View"
    Then I should see "Hello World"

  Scenario: Can't view alerts from outside jurisdictions
    Given the following entities exists:
      | Jurisdiction | Potter County                            |
      | Jurisdiction | Dallas County                            |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the following users exist:
      | Sam Body      | sam@example.com   | HAN Coordinator | Dallas County |

    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | author            | Sam Body      |
      | from_jurisdiction | Potter County |
      | title             | Hello World   |
      | jurisdiction      | Potter County |
    When I am on the alert log
    Then I should not see an alert titled "Hello World"

  Scenario: Clicking back on a viewed alert
    Given the following entities exists:
      | Jurisdiction | Texas                                    |
      | Jurisdiction | Dallas County                            |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
      | jurisdictions     | Texas |
    When I am on the alert log
    And I click "View" on "Hello World"
    And I press "Back"
    Then I should see an alert titled "Hello World"

  Scenario: Viewing percentage of recipients that have acknowledged
    Given the following entities exists:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
      | Jane Smith      | jane.smith@example.com   | HAN Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Texas                |
      | jurisdictions     | Texas, Dallas County |
      | roles             | HAN Coordinator      |
      | title             | Hello World          |
      | communication methods | Email, SMS       |
    And "jane.smith@example.com" has acknowledged the alert "Hello World"
    And "john.smith@example.com" has not acknowledged the alert "Hello World"
    And "daniel@example.com" has not acknowledged the alert "Hello World"
    When I am on the alert log
    Then I can see the alert summary for "Hello World"
    And I can see the alert for "Hello World" is 33% acknowledged
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Texas" is 33%
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Dallas County" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "E-mail" is 33%
    And I can see the device alert acknowledgement rate for "Hello World" in "Console" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "SMS" is 0%
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Phone"
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Fax"
    And I cannot see the device alert acknowledgement rate for "Hello World" in "Blackberry"
    When I press "Acknowledge"
    And I am on the alert log
    Then I can see the alert summary for "Hello World"
    And I can see the alert for "Hello World" is 67% acknowledged
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Texas" is 67%
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Dallas County" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "E-mail" is 33%
    And I can see the device alert acknowledgement rate for "Hello World" in "Console" is 33%
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
      | John Smith      | john.smith@example.com   | HAN Coordinator | R1 |
      | John Smith      | john.smith@example.com   | HAN Coordinator | C1 |
      | John Smith      | john.smith@example.com   | HAN Coordinator | R2 |
    And "john.smith@example.com" is not public in "Texas"
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I am on the alert log
    Then I should see 10 alerts

