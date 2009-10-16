Feature: Managing devices when editing user profiles
  In order to be easily reached
  as a user
  I should be able to edit my devices

  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
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
      
  Scenario: Adding an invalid device
  	When I go to the edit profile page
    And I follow "Add Device"
    And I select "E-mail" from "Device Type"
    And I fill in "E-mail" with ""
    And I press "Save"
    Then I should see error messages
    And "john.smith@example.com" should not have the communication device
      | Email |  |

  Scenario: Adding a device as an admin
  Scenario: Adding a device as an admin of a parent jurisdiction

