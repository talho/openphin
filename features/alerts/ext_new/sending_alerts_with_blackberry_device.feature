Feature: Sending alerts to BlackBerry devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my BlackBerry device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                               | Wise County    |
    And "keith.gaddis@example.com" has the following devices:
      | blackberry | 1234567890 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to Blackberry devices
    Given I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send a HAN Alert"
    And I should have the "Details" breadcrumb selected

    When  I fill in the following:
      | Title         | Chicken pox outbreak               |
      | Message       | Some body text                     |
      | Short Message | Chicken pox outbreak short message |

    And I select "Dallas County" from ext combo "Jurisdiction"
    And I select "None" from ext combo "Acknowledge"
    And I select "Test" from ext combo "Status"
    And I select "Moderate" from ext combo "Severity"
    And I check "Blackberry"
    And I press "Next"
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I press "Next"
    And I press "Send Alert"

    When delayed jobs are processed
    Then the following Blackberry calls should be made:
      | blackberry | message                            |
      | 1234567890 | Chicken pox outbreak short message |