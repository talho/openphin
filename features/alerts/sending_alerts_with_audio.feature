Feature: Sending audio alerts

  In order to be notified of an alert with audio via the phone
  As a user
  I want to people to be able to send me alerts with audio on my phone
  
  Background: 
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter

 Scenario: Sending a phone alert with an audio file
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I make changes to the alert form with:    
      | Message Recording | calm-river.wav |
    And I press "Send"
    And I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then "keith.gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | attachments   | calm-river.wav |
      
  Scenario: Sending a phone alert with an audio file
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "111-555-1212"
    And I press "Save Device"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "111-555-1212"
    And I should have a phone device with the phone "111-555-1212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | Phone |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I make changes to the alert form with:    
      | Message Recording | calm-river.wav |
    And I press "Send"
    And I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone        | message              | recording      |
      | 111-555-1212 | Chicken pox outbreak | calm-river.wav |