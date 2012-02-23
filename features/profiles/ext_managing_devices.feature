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
      | Potter Pub      | pot.pub@example.com      | Public | Potter County |
    And the following administrators exist:
      | admin@potter.gov | Potter County |

  Scenario: Adding a device
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I press "Add device"
    Then I should see "Address / Number:"
    When I select "E-mail" from ext combo "Device type"
    And I fill in "dev[value]" with "johnny@example.com"
    And I press "Add"
    Then I should see the following within ".device-item":
      | johnny@example.com | E-mail | needs to be saved |
    When I press "Apply Changes"
    Then I should not see any errors
    And "john.smith@example.com" should have the communication device
      | Email | johnny@example.com |
    And I should see the following within ".device-item":
      | johnny@example.com | E-mail |

  Scenario: Removing a device
    Given john.smith@example.com has the following devices:
      | Phone | 5552345678 |
    And I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    When I click profile-destroy "5552345678"
    Then I should not see "5552345678"
    When I press "Apply Changes"
    Then I should not see any errors
    And "john.smith@example.com" should not have the communication device
      | Phone | 5552345678 |
    And I should not see "5552345678"

  Scenario: Adding an invalid device
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I press "Add device"
    And I select "E-mail" from ext combo "Device type"
    And I press "Add"
    And I press "Apply Changes"
    Then I should see "Email address can't be blank"
    And I should see "Email address is invalid"
    And "john.smith@example.com" should not have the communication device
      | Email |  |

  Scenario: Adding a phone device with an extension is invalid
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I press "Add device"
    Then I should see "Address / Number:"
    And I select "Phone" from ext combo "Device type"
    And I fill in "dev[value]" with "5121231234x1234"
    And I press "Add"
    And I press "Apply Changes"
    Then I should see "Phone is invalid"
    And "john.smith@example.com" should not have the communication device
      | Phone |  |

  Scenario: Adding a duplicate device
    Given john.smith@example.com has the following devices:
      | Phone | 5552345678 |
    And I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I press "Add device"
    Then I should see "Address / Number:"
    And I select "Phone" from ext combo "Device type"
    And I fill in "dev[value]" with "5552345678"
    And I press "Add"
    And I press "Apply Changes"
    Then I should see "Device already exists"

  Scenario: Add and remove a device then save
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "John Smith > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I press "Add device"
    Then I should see "Address / Number:"
    And I select "SMS" from ext combo "Device type"
    And I fill in "dev[value]" with "5556667788"
    And I press "Add"
    Then I should see the following within ".device-item":
      | 5556667788 | SMS | needs to be saved |
    When I click profile-destroy "5556667788"
    Then I should not see "5556667788"
    When I press "Apply Changes"
    Then I should not see any errors
    And I should see "Profile information saved"

  Scenario: Malicious admin cannot remove devices from users they can't administer
    Given I am logged in as "admin@potter.gov"
    When I navigate to the ext dashboard page
    And I navigate to "Default FactoryUser > Manage Devices"
    And I wait for the "Loading..." mask to go away
    And I will confirm on next step
    And I maliciously post a destroy for a device for "john.smith@example.com"
    And delayed jobs are processed
    Then "john.smith@example.com" should have the communication devices
      | Email | john.smith@example.com |
