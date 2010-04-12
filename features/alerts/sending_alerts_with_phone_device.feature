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
      | Acknowledge | None |
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
      | Acknowledge | Normal |
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
    When I go to the alert log
    Then I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 0%
    
    When "keith.gaddis@example.com" acknowledges the phone alert
    And delayed jobs are processed
    And I go to the alert log
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
      | Acknowledge | None |
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


  Scenario: Sending alerts with call down
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

    When I fill in "Title" with "H1N1 SNS push packs to be delivered tomorrow"
    And I fill in "Short Message" with "Chicken pox outbreak"
    And I select "Actual" from "Status"
    And I select "Moderate" from "Severity"
    And I select "Advanced" from "Acknowledge"
    And I check "Wise County"
    And I check "Phone"
    # And I press "Use Call Down"
    And I fill in "Alert Response 1" with "if you can respond within 15 minutes"
    And I fill in "Alert Response 2" with "if you can respond within 30 minutes"
    And I fill in "Alert Response 3" with "if you can respond within 1 hour"
    And I fill in "Alert Response 4" with "if you can respond within 4 hours"
    And I fill in "Alert Response 5" with "if you cannot respond"

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           | call_down                            |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  Chicken pox outbreak | if you can respond within 15 minutes |
    And the phone call should have 5 calldowns
