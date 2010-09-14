Feature: Sending alerts to phones

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my phone

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                               | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to phone devices
    # legacy code because the profile page has not been converted yet
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    #end legacy code: replace when we've converted user profiles

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the following:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | There is a Chicken pox outbreak in the area  |
      | Short Message | Chicken pox outbreak                         |
    And I check "Phone"
    And I select "Moderate" from ext combo "Severity"
    And I select "Actual" from ext combo "Status"
    And I select "None" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type |
      | Keith Gaddis  | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

  Scenario: Sending alerts to phone devices with acknowledgment
    # legacy code because the profile page has not been converted yet
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    #end legacy code: replace when we've converted user profiles

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the following:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | There is a Chicken pox outbreak in the area  |
      | Short Message | Chicken pox outbreak                         |
    And I check "Phone"
    And I select "Moderate" from ext combo "Severity"
    And I select "Actual" from ext combo "Status"
    And I select "Normal" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type |
      | Keith Gaddis  | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

    # legacy code since we haven't converted the alert log to EXT yet
    When I go to the alert log
    And I follow "More"
    Then I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 0%

    When "keith.gaddis@example.com" acknowledges the phone alert
    And delayed jobs are processed
    And I go to the alert log
    And I follow "More"
    Then I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 100%
    #end legacy code

  Scenario: Sending alerts to users with multiple phone devices
    # legacy code because the profile page has not been converted yet
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    And I follow "Add Device"
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
    #end legacy code: replace when we've converted user profiles

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the following:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | There is a Chicken pox outbreak in the area  |
      | Short Message | Chicken pox outbreak                         |
    And I check "Phone"
    And I select "Moderate" from ext combo "Severity"
    And I select "Actual" from ext combo "Status"
    And I select "None" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type |
      | Keith Gaddis  | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 2105551213 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

  Scenario: Sending alerts with call down
    # legacy code because the profile page has not been converted yet
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "210-555-1212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    #end legacy code: replace when we've converted user profiles

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I select "Advanced" from ext combo "Acknowledge"
    # add a 3rd, 4th and 5th response box
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I fill in the following:
      | Title            | H1N1 SNS push packs to be delivered tomorrow |
      | Message          | There is a Chicken pox outbreak in the area  |
      | Short Message    | Chicken pox outbreak                         |
      | Alert Response 1 | if you can respond within 15 minutes         |
      | Alert Response 2 | if you can respond within 30 minutes         |
      | Alert Response 3 | if you can respond within 1 hour             |
      | Alert Response 4 | if you can respond within 4 hours            |
      | Alert Response 5 | if you cannot respond                        |
    And I check "Phone"
    And I select "Moderate" from ext combo "Severity"
    And I select "Actual" from ext combo "Status"
    And I select "Dallas County" from ext combo "Jurisdiction"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type |
      | Keith Gaddis  | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  | call_down                            |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area | if you can respond within 15 minutes |
    And the phone call should have 5 calldowns
