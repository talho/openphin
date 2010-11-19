Feature: Viewing recent alerts on dashboard

  In order to easily be informed of recent alerts
  As a user
  I want see alerts sent to me on the dashboard

  Background:
    Given the following entities exist:
      | Jurisdiction | Dallas County  |
      | Role         | Epidemiologist |
    And the following users exist:
      | Martin Fowler      | martin@example.com   | Epidemiologist | Dallas County |

  Scenario: User should see the example alert if no alerts exist
    Given I am logged in as "martin@example.com"
    When I go to the han page
    Then I should see an alert with the summary:
      | title       | Example Health Alert - please click More to see the alert contents |
      | severity    | Minor                                                              |
      | status      | Test                                                               |
    And I should see an alert with the detail:
      | message     | This is an example of a health alert. |
      | acknowledge | No                                    |
      | sensitive   | No                                    |

  Scenario: User should see the 20 most recent alerts sent to them
    Given a sent alert with:
      | title       | rolling pig pox     |
      | message     | the world is on fie |
      | status      | Actual              |
      | severity    | Moderate            |
      | acknowledge | Yes                 |
      | people      | Martin Fowler       |
    And I am logged in as "martin@example.com"  
    When I go to the han page
    Then I should see an alert with the summary:
      | title       | rolling pig pox |
      | severity    | Moderate |
    And I should see an alert with the detail:
      | message     | the world is on fie |
      | acknowledge | Yes      |
    
    Given 19 more alerts are sent to me
    When delayed jobs are processed
    And I go to the han page
    Then I should see 10 alerts
    When I follow "Next"
    Then I should see 10 alerts
    And I should see an alert with the summary:
      | title       | rolling pig pox |
      | severity    | Moderate        |
    And I should see an alert with the detail:
      | message     | the world is on fie |
      | acknowledge | Yes                 |

    Given 1 more alert is sent to me
    When delayed jobs are processed
    And I go to the han page
    Then I should see 10 alerts
    And I should not see an alert titled "rolling pig pox"
    When I follow "Next"
    Then I should see 10 alerts
    When I follow "Next"
    Then I should see 1 alert
  
  
  
  