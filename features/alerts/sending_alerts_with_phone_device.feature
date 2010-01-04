Feature: Sending alerts to phones

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my phone
  
  Background: 
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
  
  Scenario: Sending alerts to phone devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Short Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | Phone |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  Chicken pox outbreak |
    
  Scenario: Sending alerts to phone devices with acknowledgment
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Short Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <checked> |
      | Communication methods | Phone |
      | Sensitive | <unchecked> |
      
    And I press "Preview Message"
    Then I should see a preview of the message
    
    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  Chicken pox outbreak |
    And I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 0%
    
    When "keith.gaddis@example.com" acknowledges the phone alert
    And delayed jobs are processed
    And I go to the Alerts page
    Then I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 100%

  Scenario: Sending alerts to users with multiple phone devices
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1213"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    Then I should see "2105551213"
    And I should have a phone device with the phone "2105551212"
    And I should have a phone device with the phone "2105551213"
    And I sign out

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Short Message | Chicken pox outbreak |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | Phone |
      | Sensitive | <unchecked> |

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  Chicken pox outbreak |
      | 2105551213 | The following is an alert from the Texas Public Health Information Network.  Chicken pox outbreak |
