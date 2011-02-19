Feature: Sending alerts to BlackBerry devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my BlackBerry device

  Background:
    Given the following entities exist:
      | Jurisdiction | Dallas County                               |
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Public                                      |
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
      | Bill Smith      | bill.smith@example.com   | Public                                       | Dallas County  |
    And "bill.smith@example.com" has the following devices:
      | blackberry | 12345678 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to Blackberry devices
    Given I log in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults
    And I check "Blackberry"
    And I uncheck "E-mail"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak short message"

    And I select the following alert audience:
      | name         | type |
      | Bill Smith   | User |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    When delayed jobs are processed
    Then the following Blackberry calls should be made:
      | blackberry | message                            |
      | 12345678   | Chicken pox outbreak short message |