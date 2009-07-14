Feature: Creating and sending alerts
  In order to notify others in a timely fashion
  As a user
  I can create and send alerts
  
  Background: 
    Given the following entities exists:
      | Organization | Red Cross             |
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Jurisdiction | Wise County           |
      | Jurisdiction | Potter County         |
      | Jurisdiction | Texas                 |
      | Role         | Health Officer        |
      | Role         | Immunization Director |
      | Role         | Epidemiologist        |
      | Role         | WMD Coordinator       |
    And the following people exist:
      | John Smith      | john.smith@example.com     | Health Officer  | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com    | Health Officer  | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com   | Epidemiologist  | Wise County    |
      | Jason Phipps    | jason.phipps@example.com   | WMD Coordinator | Potter County  |
      | Brandon Keepers | branon.keepers@example.com | Health Officer  | Texas          |
      
  Scenario: Sending a custom alert directly to a person
    Given I am logged in as "john.smith@example.com"
    And I can send alerts
    When I go to the Alerts page
    And I click "New Alert"

    And I select the People
      | Keith Gaddis |
    And I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"
    And I fill in "Body" with "For more details, keep on reading..."
    And I select "Moderate" from "Severity"
    And I select "Actual" from "Status"
    And I uncheck "Acknowledgement"
    And I select the following communication methods:
      | Email |
      
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And "keith@gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |
      
  Scenario: Sending a sensitive alert
  
  Scenario: Sending an alert with specified Roles/Jurisdictions scopes alerts to those Roles/Jurisdictions
  
  Scenario: Sending an alert to an Organizations sends alerts to all people within those organizations
  
  Scenario: Sending an alert to specific people sends alerts to each person
    
  Scenario: Sending a secure alert
    # And I check "Secure"
  
  Scenario: Sending an alert that requires user acknowledgement
    # acknowledgement shows up in email
  
  Scenario: Sending an alert via multiple communication methods
  
  Scenario: Sending an alert with a short message to communication devices that accept short messages
  
  Scenario: Currently logged in user receives an alert should notify them of the new alert
  