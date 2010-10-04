Feature: Sending alerts to BlackBerry devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my BlackBerry device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                               | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to SMS devices
    # Start legacy code: we don't have the profile working in EXT yet
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
    # End legacy code. replace when profile is in EXT

    Given I log in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults
    And I check "Blackberry"
    And I uncheck "E-mail"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak short message"

    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |

    And I send the alert

    When delayed jobs are processed
    Then the following Blackberry calls should be made:
      | blackberry | message                            |
      | 12345678   | Chicken pox outbreak short message |