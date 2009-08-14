Feature: Users with an alerter role

  Scenario: Sending an alert without an alerter role
    Given the following users exist:
      | John Smith      | john.smith@example.com     | Health Officer  | Dallas County  |
    And I am logged in as "john.smith@example.com"
    When I go to the new alert page
    Then I should see "You do not have permission to send an alert."
    
  Scenario: Sending an alert with multiple alerter roles
