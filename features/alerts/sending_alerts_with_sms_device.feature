Feature: Sending alerts to phones

  In order to be notified of an alert via SMS
  As a user
  I want people to be able to send me alerts on my SMS device
  
  Background: 
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
  
  Scenario: Sending alerts to phone devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "SMS" from "Device Type"
    And I fill in "SMS" with "111-555-1212"
    And I press "Save Device"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "111-555-1212"
    And I should have a SMS device with the SMS number "111-555-1212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Chicken pox outbreak long Message |
      | Short Message | Chicken pox outbreak short message|
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | SMS |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following SMS calls should be made:
      | sms          | message              |
      | 111-555-1212 | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow Chicken pox outbreak short message |