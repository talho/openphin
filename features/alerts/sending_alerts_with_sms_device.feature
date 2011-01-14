Feature: Sending alerts to SMS devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my SMS device
  
  Background:
    Given the following entities exists:
      | Role          | Health Alert and Communications Coordinator |
      | Role          | Epidemiologist                              |
      | Jurisdiction  | Dallas County                               |
      | Jurisdiction  | Wise County                                 |
    Given the following users exist:
      | John Smith   | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
      | Keith Gaddis | keith.gaddis@example.com | Epidemiologist                              | Wise County   |
    And "Texas" is the parent jurisdiction of:
      | Dallas County |
      | Wise County   |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed
  
  Scenario: Sending alerts to SMS devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "SMS" from "Device Type"
    And I fill in "SMS" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a SMS device with the SMS number "2105551212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    When I fill out the alert form with:
      | People                | Keith Gaddis                                 |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | Chicken pox outbreak long Message            |
      | Short Message         | Chicken pox outbreak short message           |
      | Severity              | Moderate                                     |
      | Status                | Actual                                       |
      | Acknowledge           | None                                         |
      | Communication methods | SMS                                          |
      | Caller ID             | 1234567890                                   |
      | Sensitive             | <unchecked>                                  |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following SMS calls should be made:
      | sms         | message                            |
      | 12105551212 | Chicken pox outbreak short message |

  Scenario: Require Caller ID for Phone Alerts
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "SMS" from "Device Type"
    And I fill in "SMS" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a SMS device with the SMS number "2105551212"
    And I sign out

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"

    When I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"
    And I fill in "Message" with "There is a Chicken pox outbreak in the area"
    And I fill in "Short message" with "Chicken pox outbreak"
    And I select "Actual" from "Status"
    And I select "Moderate" from "Severity"
    And I check "SMS"

    Then I will confirm on next step
    And I press "Select an Audience"
    Then I should see "You must provide a Caller ID number" within the alert box