Feature: Sending sensitive alerts

  In order to ....
  As a ...
  I want to ....

  Scenario: Sending a sensitive email alert
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
      | Sensitive | <checked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Sensitive: use secure means of retrieval |
      | body does not contain | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body does not contain | For more details, keep on reading... |
