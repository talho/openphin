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
  	When I go to the edit profile page
    And I follow "Add Device"
    And I select "E-mail" from "Device Type"
    And I fill in "E-mail" with "johnny@example.com"
    And I press "Save"
    Then "john.smith@example.com" should have the communication device
      | Email | johnny@example.com |
  	When I go to the edit profile page
    Then I should see in my list of devices
      | Email | johnny@example.com |

  Scenario: Removing a device as a user
    Given john.smith@example.com has the following devices:
      | Phone | 5552345678 |
    When I go to the edit profile page
    And I will confirm on next step
    And I follow "Delete Phone"
    Then I should not see "5552345678"
    And "john.smith@example.com" should not have the communication device
      | Phone | 5552345678 |

  Scenario: Adding an invalid device
  	When I go to the edit profile page
    And I follow "Add Device"
    And I select "E-mail" from "Device Type"
    And I fill in "E-mail" with ""
    And I press "Save"
    Then I should see error messages
    And "john.smith@example.com" should not have the communication device
      | Email |  |

  Scenario: Adding a phone device with an extension is invalid
  	When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "5121231234x1234"
    And I press "Save"
    Then I should see error messages
    And "john.smith@example.com" should not have the communication device
      | Phone |  |

  Scenario: Malicious admin cannot remove devices from users they can't administer
    Given I am logged in as "admin@potter.gov"
    And I am on the dashboard page
    When I will confirm on next step
    And I maliciously post a destroy for a device for "john.smith@example.com"
    Then I should see "This resource does not exist or is not available."
    And I should be on the dashboard page

  Scenario: Adding a device as an admin
  Scenario: Adding a device as an admin of a parent jurisdiction
    
