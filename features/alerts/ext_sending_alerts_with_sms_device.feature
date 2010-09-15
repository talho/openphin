Feature: Sending alerts to SMS devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my SMS device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                              | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to SMS devices
    # using legacy code because we have not updated user profile yet
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
    # end legacy code

    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the following:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | Chicken pox outbreak long Message            |
      | Short Message | Chicken pox outbreak short message           |
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I select "Moderate" from ext combo "Severity"
    And I select "Actual" from ext combo "Status"
    And I select "None" from ext combo "Acknowledge"
    And I check "SMS"
    
    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    When delayed jobs are processed
    Then the following SMS calls should be made:
      | sms         | message                            |
      | 12105551212 | Chicken pox outbreak short message |