@ext
Feature: Sending sensitive alerts

  In order to not cause panic
  As a user
  I want to be able to keep sensitive alerts private

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                              | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

  Scenario: Sending a sensitive email alert
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."
    And I check "Sensitive"

    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open
    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Sensitive: use secure means of retrieval |
      | body does not contain | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body does not contain | For more details, keep on reading... |
