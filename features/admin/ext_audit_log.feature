Feature: Audit Log
  In order to keep tabs on the system and spot issues more effectively
  As a site administrator
  I want to be able to track every create, update, and destroy on the system

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas                                       |
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Boss                                        |
      | Role         | Lackey                                      |
      | Role         | Sous Chef                                   |

    And Texas is the parent jurisdiction of:
     | Region 1, Region 2 |
    And Region 1 is the parent jurisdiction of:
     | Dallas County, Travis County |
    And Region 2 is the parent jurisdiction of:
     | Lubbock County, Denton County |
    And the following users exist:
      | Jane Smith | janesmith@example.com | Boss                                        | Dallas County  |
      | Fred Smith | fredsmith@example.com | Lackey                                      | Lubbock County |
      | Sara Smith | sarasmith@example.com | Health Alert and Communications Coordinator | Lubbock County |
    And Dallas County has the following administrators:
      | Bill Smith | billsmith@example.com |
    And the role "Health Alert and Communications Coordinator" is an alerter

  Scenario: Pagination
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I should see "Displaying Events 1 - 30 of"
    #TODO: click the next page and verify

  Scenario: View all events for a specific record
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | No                      |
      | from_jurisdiction     | Dallas County           |
      | communication methods | Email                   |
      | people                | Jane Smith              |
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away
    And I explicitly click x-grid3-cell-inner "TEST ALERT"
    And I wait for the "Fetching Version Data..." mask to go away
    When I press "Event 4 of 4" 
    And I wait for the "Loading..." mask to go away
    Then I should see 4 rows in grid "grid-version-results"

  Scenario: Step forward and backward in record history  
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | No                      |
      | from_jurisdiction     | Dallas County           |
      | communication methods | Email                   |
      | people                | Jane Smith              |
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away
    And I explicitly click x-grid3-cell-inner "TEST ALERT"
    And I wait for the "Fetching Version Data..." mask to go away
    Then I should see "Event 4 of 4"
    When I press "Older"
    Then I should see "Event 3 of 4"
    When I press "Older"
    Then I should see "Event 2 of 4"
    When I press "Older"
    Then I should see "Event 1 of 4"
    When I press "Newer"
    Then I should see "Event 2 of 4"
    When I press "Newer"
    Then I should see "Event 3 of 4"

  Scenario: View only creates, updates, or destroys
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away
    And I uncheck "Create"
    And I wait for the "Loading..." mask to go away
    Then I should see "update" in column "Action" within "grid-version-results"
    Then I should not see "create" in column "Action" within "grid-version-results"

  Scenario: Audit log for Han Alert model
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | No                      |
      | from_jurisdiction     | Dallas County           |
      | communication methods | Email                   |
      | people                | Jane Smith              |
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    And I click model-selector-list-item "Han Alerts"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 4 rows in grid "grid-version-results"
    And I click model-selector-list-item "Han Alerts"
    And I click model-selector-list-item "Alert Attempts"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 4 rows in grid "grid-version-results"
    And I click model-selector-list-item "Alert Attempts"
    And I click model-selector-list-item "Audiences"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 2 rows in grid "grid-version-results"
    And I click model-selector-list-item "Audiences"
    And I click model-selector-list-item "Deliveries"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 2 rows in grid "grid-version-results"
    And I click model-selector-list-item "Deliveries"
    And I click model-selector-list-item "Targets"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 2 rows in grid "grid-version-results"
    And I click model-selector-list-item "Targets"
    And I click model-selector-list-item "Alert Ack Logs"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see 8 rows in grid "grid-version-results"

  Scenario: Audit log for Forums
    Given I am logged in as "billsmith@example.com"
    And I have the comment "TEST REPLY" to topic "TEST TOPIC" to forum "TEST FORUM"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    When I click model-selector-list-item "Forums"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "TEST FORUM" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Forums"
    When I click model-selector-list-item "Topics"
    And I wait for the "Loading..." mask to go away for 1 second
    And I should see "TEST TOPIC" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Topics"
    When I click model-selector-list-item "Audiences"
    And I wait for the "Loading..." mask to go away for 1 second
    And I should see "anonymous" in column "Descriptor" within "grid-version-results"
    And I explicitly click x-grid3-cell-inner "anonymous"
    And I wait for the "Fetching Version Data..." mask to go away
    Then I should see "TEST FORUM" in column "Current Version" within "panel-version-display"

  Scenario: Audit log for Editing Profile and Devices
    Given the user "TEST USER" with the email "TESTUSER@EXAMPLE.COM" has the role "Lackey" in "Dallas County"
    And "TESTUSER@EXAMPLE.COM" has the title "TEST TITLE"
    And TESTUSER@EXAMPLE.COM has the following devices:
      | phone | 2134567890 |
    And "TESTUSER@EXAMPLE.COM" has requested to be a "Sous Chef" for "Lubbock County"
    And I am logged in as "billsmith@example.com"
    And I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    When I click model-selector-list-item "Users"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "TEST USER" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Users"
    When I click model-selector-list-item "Devices"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "2134567890" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Devices"
    When I click model-selector-list-item "Role Memberships"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "TEST USER, Lackey in Dallas County" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Role Memberships"
    When I click model-selector-list-item "Role Requests"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "TEST USER for Sous Chef in Lubbock County" in column "Descriptor" within "grid-version-results"

#  Scenario: Audit log for Documents
#    pending #document step definitions are working
#    Given I am logged in as "billsmith@example.com"
#    And I navigate to the ext dashboard page
#    And I have a folder named "TESTFOLDERONE"
#    And I have the document "TESTFILE1.TXT" in "TESTFOLDERONE"
#    And I have the document "TESTFILE2.JPG" in "TESTFOLDERTWO"
#    And I share "TESTFOLDERONE" with the following audience:
#      | emails        | sarasmith@example.com, fredsmith@example.com |
#      | roles         | Boss                                         |
#      | jurisdictions | Dallas County                                |
#    And I navigate to "Admin > Audit Log"
#    Then the "Audit Log" tab should be open
#    And I wait for the "Loading..." mask to go away for 1 second

  Scenario: Audit log for Invitations
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And an Invitation "TEST INVITATION" exists with:
      | Subject      | YOU ARE INVITED TO TEST |
      | Organization | TALHO                   |
      | Body         | COME ONE COME ALL       |
    And invitation "TEST INVITATION" has the following invitees:
      | INVITEE ONE | INVITEEONE@EXAMPLE.COM |
      | INVITEE TWO | INVITEETWO@EXAMPLE.COM |
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    When I click model-selector-list-item "Invitations"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "TEST INVITATION" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Invitations"
    When I click model-selector-list-item "Invitees"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "INVITEE ONE" in column "Descriptor" within "grid-version-results"
    Then I should see "INVITEE TWO" in column "Descriptor" within "grid-version-results"
    And I explicitly click x-grid3-cell-inner "INVITEE ONE"
    And I wait for the "Fetching Version Data..." mask to go away
    Then I should see "TEST INVITATION" in column "Current Version" within "panel-version-display"

  Scenario: Audit log for Organizations
    Given there is an unapproved "SILLY HATS ONLY" organization with "fredsmith@example.com" as the contact
    And the organization "SILLY HATS ONLY" has been approved
    And I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And "janesmith@example.com" has requested membership in organization "SILLY HATS ONLY"
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    When I click model-selector-list-item "Organizations"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "SILLY HATS ONLY" in column "Descriptor" within "grid-version-results"
    And I click model-selector-list-item "Organizations"
    When I click model-selector-list-item "Organization Membership Requests"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "Jane Smith in SILLY HATS ONLY" in column "Descriptor" within "grid-version-results"

  Scenario: Audit log for Favorites
    Given I am logged in as "billsmith@example.com"
    And I navigate to the ext dashboard page
    And I press "Find People"
    Then the "Find People" tab should be open
    And I drag the "Find People" tab to "#favoritestoolbar"
    And I navigate to "Admin > Audit Log"
    Then the "Audit Log" tab should be open
    And I wait for the "Loading..." mask to go away for 1 second
    When I click model-selector-list-item "Favorites"
    And I wait for the "Loading..." mask to go away for 1 second
    Then I should see "Find People" in column "Descriptor" within "grid-version-results"