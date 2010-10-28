Feature: Managing devices when editing user profiles
  In order to be easily reached
  as a user
  I should be able to edit my devices

  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Federal        |
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And Federal is the parent jurisdiction of:
      | Texas |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And the following administrators exist:
      | admin@potter.gov | Potter County |
    And I am logged in as "john.smith@example.com"
		
  Scenario: Adding a device
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I press "Add device"
    And I select "E-mail" from ext combo "Device type"
    And I fill in "Device info" with "johnny@example.com"
    And I press "Add"
    Then I should see the following within ".device-item":
      | johnny@example.com | E-mail | needs to be saved |
    When I press "Save"
    Then I should not see any errors
    And "john.smith@example.com" should have the communication device
      | Email | johnny@example.com |
    And I should see the following within ".device-item":
      | johnny@example.com | E-mail |

  Scenario: Removing a device
    Given john.smith@example.com has the following devices:
      | Phone | 5552345678 |
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    When I click device-item "5552345678"
    And I press "Remove device"
    Then I should not see "5552345678"
    When I press "Save"
    Then I should not see any errors
    And "john.smith@example.com" should not have the communication device
      | Phone | 5552345678 |
    And I should not see "5552345678"

  Scenario: Adding an invalid device
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I press "Add device"
    And I select "E-mail" from ext combo "Device type"
    And I press "Add"
    And I press "Save"
    Then I should see "Email address can't be blank"
    And I should see "Email address is invalid"
    And "john.smith@example.com" should not have the communication device
      | Email |  |

  Scenario: Adding a phone device with an extension is invalid
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I press "Add device"
    And I select "Phone" from ext combo "Device type"
    And I fill in "Device info" with "5121231234x1234"
    And I press "Add"
    And I press "Save"
    Then I should see "Phone is invalid"
    And "john.smith@example.com" should not have the communication device
      | Phone |  |

  Scenario: Adding a duplicate device
    Given john.smith@example.com has the following devices:
      | Phone | 5552345678 |
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I press "Add device"
    And I select "Phone" from ext combo "Device type"
    And I fill in "Device info" with "5552345678"
    And I press "Add"
    And I press "Save"
    Then I should see "Device already exists"

  Scenario: Add and remove a device then save
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I press "Add device"
    And I select "SMS" from ext combo "Device type"
    And I fill in "Device info" with "5556667788"
    And I press "Add"
    Then I should see the following within ".device-item":
      | 5556667788 | SMS | needs to be saved |
    When I click device-item "5556667788"
    And I press "Remove device"
    Then I should not see "5556667788"
    When I press "Save"
    Then I should not see any errors
    And I should see "Devices saved"

  Scenario: Malicious admin cannot remove devices from users they can't administer
    Given I am logged in as "admin@potter.gov"
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Devices"
    And I will confirm on next step
    And I maliciously post a destroy for a device for "john.smith@example.com"
    Then I should see "This resource does not exist or is not available."
    And I should be on the dashboard page
