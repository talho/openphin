Feature: Viewing recent alerts on dashboard

  In order to easily be informed of recent alerts
  As a user
  I want see alerts sent to me on the dashboard
  
  Scenario: User should see the 20 most recent alerts sent to them
    Given the following users exist:
      | Martin Fowler      | martin@example.com   | Public | Dallas County |
    And a sent alert with:
      | title       | rolling pig pox |
      | message     | the world is on fie |
      | status      | Actual   |
      | severity    | Moderate |
      | acknowledge | Yes      |
      | people      | Martin Fowler |
    And I am logged in as "martin@example.com"
    
    When I go to the dashboard page
    Then I should see an alert with the summary:
      | title       | rolling pig pox |
      | severity    | Moderate |
    And I should see an alert with the detail:
      | message     | the world is on fie |
      | acknowledge | Yes      |

    Given 19 more alerts are sent to me
    When I go to the dashboard page
    Then I should see 20 alerts
    And I should see an alert with the summary:
      | title       | rolling pig pox |
      | severity    | Moderate |
    And I should see an alert with the detail:
      | message     | the world is on fie |
      | acknowledge | Yes      |
    
    Given 1 more alert is sent to me
    When I go to the dashboard page
    Then I should see 20 alerts
    And I should not see an alert titled "rolling pig pox"
  
  
  
  