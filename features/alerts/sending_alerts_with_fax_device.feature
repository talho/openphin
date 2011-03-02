Feature: Sending alerts to faxes
#
#  In order to be notified of an alert
#  As a user
#  I want people to be able to send me alerts on my Fax machine
#
#  Background:
#    Given the following entities exists:
#      | Role          | Health Alert and Communications Coordinator |
#      | Role          | Epidemiologist                              |
#      | Jurisdiction  | Dallas County                               |
#      | Jurisdiction  | Wise County                                 |
#    And the following users exist:
#      | John Smith   | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
#      | Keith Gaddis | keith.gaddis@example.com | Epidemiologist                              | Wise County   |
#    And the role "Health Alert and Communications Coordinator" is an alerter
#    And delayed jobs are processed
  
#  Scenario: Sending alerts to fax devices
#    Given we start supporting fax again
#    Given I am logged in as "keith.gaddis@example.com"
#    When I go to the edit profile page
#    And I follow "Add Device"
#    And I select "Fax" from "Device Type"
#    And I fill in "Fax" with "210-555-1212"
#    And I press "Save"
#    Then I should see "Profile information saved."
#    When I go to the edit profile page
#    Then I should see "2105551212"
#    And I should have a Fax device with the Fax number "2105551212"
#    And I sign out
#
#    Given I log in as "john.smith@example.com"
#    And I am allowed to send alerts
#    When I go to the han page
#    And I follow "Send an Alert"
#    When I fill out the alert form with:
#      | People                | Keith Gaddis                                 |
#      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
#      | Message               | Chicken pox outbreak                         |
#      | Severity              | Moderate                                     |
#      | Status                | Actual                                       |
#      | Acknowledge           | None                                         |
#      | Communication methods | Fax                                          |
#      | Sensitive             | <unchecked>                                  |
#
#    And I press "Preview Message"
#    Then I should see a preview of the message
#
#    When I press "Send"
#    Then I should see "Successfully sent the alert"
#
#    When delayed jobs are processed
#    Then the following Fax calls should be made:
#      | fax          | message              |
#      | 2105551212 | Chicken pox outbreak |