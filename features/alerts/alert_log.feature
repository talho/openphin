Feature: Viewing the alert log

  Scenario: Viewing list of alerts in your jurisdictions
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
    When I am on the alert log
    Then I should see an alert titled "Hello World"
    
    When I click "View" on "Hello World"
    Then I can see the alert summary for "Hello World"
    
   Scenario: Viewing list of alerts sent directly to you
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
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
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
    When I am on the alert log
    Then I should see an alert titled "Hello World"
  
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
    When I am on the alert log
    And I click "View" on "Hello World"
    And I follow "Back"
    Then I should see an alert titled "Hello World" 
    
  Scenario: Viewing percentage of recipients that have acknowledged     
    Given the following entities exists:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
      | Daniel Morrison | daniel@example.com       | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And an alert with:
      | from_jurisdiction | Texas                |
      | jurisdictions     | Texas, Dallas County |
      | roles             | HAN Coordinator      |
      | title             | Hello World          |
    And "john.smith@example.com" has acknowledged the alert "Hello World"
    And "daniel@example.com" has not acknowledged the alert "Hello World"
    When I am on the alert log
    Then I can see the alert summary for "Hello World"
    And I can see the alert for "Hello World" is 50% acknowledged
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Texas" is 50%
    And I can see the jurisdiction alert acknowledgement rate for "Hello World" in "Dallas County" is 0%
    And I can see the device alert acknowledgement rate for "Hello World" in "E-mail" is 50%

  Scenario: Viewing jurisdictions, organizations, roles and individual users that received an alert