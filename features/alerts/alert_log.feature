Feature: Viewing the alert log

  Scenario: Viewing list of alerts in your jurisdictions
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And an alert with:
      | from_jurisdiction | Dallas County |
      | title             | Hello World   |
    When I view the alert log
    Then I should see an alert title "Hello World"
    
  Scenario: Viewing list of alerts in child jurisdictions
  
  Scenario: Can't view alerts from outside jurisdictions
  
  Scenario: Viewing an alert in the log
  # show "active" (time hasn't run out) 72h, 24h, 60m, 15m
  
  Scenario: Viewing percentage of recipients that have acknowledged
  Scenario: Viewing percentage of recipients that have acknowledged by jurisdiction
  Scenario: Viewing percentage of acknowledgements by device type
  Scenario: Viewing jurisdictions, organizations, roles and individual users that received an alert