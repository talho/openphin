Feature: Sending alerts to phones

  In order to be notified of an alert via Fax
  As a user
  I want people to be able to send me alerts on my Fax machine
  
  Background: 
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
  
  Scenario: Sending alerts to fax devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "Fax" from "Device Type"
    And I fill in "Fax" with "111-555-1212"
    And I press "Save Device"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "111-555-1212"
    And I should have a Fax device with the Fax number "111-555-1212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Dashboard page
    And I follow "Send an Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | Fax |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following Fax calls should be made:
      | fax          | message              |
      | 111-555-1212 | Chicken pox outbreak |