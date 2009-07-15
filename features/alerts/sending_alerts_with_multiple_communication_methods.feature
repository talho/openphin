Feature: Sending alerts to multiple communication devices

  In order to ....
  As a ...
  I want to ....

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And I am logged in as "john.smith@example.com"
    And "keith.gaddis@example.com" has an IM device
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"

  Scenario: Sending an alert via multiple communication methods
    When I fill out the alert form with:
      | People   | Keith Gaddis                                 |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Severity | Moderate                                     |
      | Status   | Actual                                       |
      | Acknowledge | <unchecked>                               |
      | Communication methods | E-mail                          |
      | Communication methods | IM                              |

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    And "keith.gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
    And "keith.gaddis@example.com" should receive the IM:
      | contains      | Moderate Health Alert from Dallas County : John Smith : Health Officer |
    