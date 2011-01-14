Feature: Sending alerts to BlackBerry devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my BlackBerry device
  
  Background: 
    Given the following entities exist:
      | Jurisdiction | Dallas County                               |
      | Jurisdiction | Wise County                                 |
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Epidemiologist                              |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                              | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed
    
  Scenario: Sending alerts to SMS devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Blackberry PIN" from "Device Type"
    And I fill in "Blackberry" with "12345678"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "12345678"
    And I should have a Blackberry device with the Blackberry number "12345678"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the han page
    And I follow "Send an Alert"

    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow  |
      | Message               | Chicken pox outbreak long Message             |
      | Short Message         | Chicken pox outbreak short message            |
      | Severity              | Moderate                                      |
      | Status                | Actual                                        |
      | Acknowledge           | None                                          |
      | Communication methods | Blackberry                                    |
      | Sensitive             | <unchecked>                                   |
      | People                | Keith Gaddis                                  |
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following Blackberry calls should be made:
      | blackberry   | message                            |
      | 12345678     | Chicken pox outbreak short message |
