Feature: Sending sensitive alerts

  In order to not cause panic
  As a user
  I want to be able to keep sensitive alerts private
  
  Background: 
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts

  Scenario: Sending a sensitive email alert
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert "Details" form with:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | For more details, keep on reading... |
      | Severity      | Moderate            |
      | Status        | Actual              |
      | Acknowledge   | None                |
      | Sensitive     | <checked>           |
    And I check "E-mail"
    And I press "Select an Audience"
    And delayed jobs are processed
    And I fill out the alert "Audience" form with:
      | Jurisdictions | Dallas County       |
      | Roles         | Health Officer      |
      | People        | Keith Gaddis        |
    And I press "Preview Message"
    Then I should see a preview of the message
      
    When I press "Send this Alert"
    Then I should see "Successfully sent the alert"
    And I should be on the alert log
    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Sensitive: use secure means of retrieval |
      | body does not contain | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body does not contain | For more details, keep on reading... |
