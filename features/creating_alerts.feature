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
      | John Smith   | Health Officer    | Dallas County |
      | Ethan Waldo  | Health Officer    | Tarrant County |
      | Keith Gaddis | Epidemiologist    | Wise County |
      | Jason Phipps | WMD Coordinator   | Potter County |
      | Brandon Keepers | Health Officer | Texas |
      
  Scenario: Sending a custom alert
    Given I am logged in and can alert in "Dallas County"
    When I go to the Alerts page
    And I click "New Alert"
    And I choose the Roles
      | Health Officer        | 
      | Immunization Director |
    And I choose the Jurisdictions
      | Dallas County  |
      | Tarrant County |
    And I select the Organizations
      | Red Cross |
    And I select the People
      | Keith Gaddis |
    
    And I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"
    And I fill in "Body" with "For more details, keep on reading..."
    And I select "Moderate" from "Severity"
    
    And I uncheck "Acknowledgement"
    And I select the following communication methods:
      | Email |
      
  Scenario: Sending an alert with specified Roles/Jurisdictions scopes messages to those Roles/Jurisdictions
  
  Scenario: Sending an alert to Organizations sends messages to all people within those organizations
  
  Scenario: Sending an alert to specific people sends alerts directly to those people
    
  Scenario: Sending a secure alert
    # And I check "Secure"
  Scenario: Sending an alert that requires user acknowledgement
  Scenario: Sending an alert via multiple communication methods