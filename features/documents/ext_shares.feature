@ext
Feature: Document Sharing

  In order to facilitate the transferal of documents
  As a user
  I want to be able to set my folders as shared and have other people view them

  Background: Create users
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin  | Potter County |
    And delayed jobs are processed
    And I am logged in as "bartleby@example.com"

  Scenario: Create a shared folder
    And I go to the ext dashboard page
    When I navigate to "Documents"
    And I press "Add Folder"
    And I fill in "Folder Name" with "Shared Folder"
    And I click x-tab-strip-text "Sharing"
    And I check "Shared - Accessible to the audience specified below"
    And I select the following in the audience panel:
      | name          | type | 
      | Atticus Finch | User |
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I sign out

    When I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    Then I should see "Bartleby Scrivener" in grid row 2
    When I expand the folders "Bartleby"
    Then I should see "Shared Folder" in grid row 3

  Scenario: Edit a folder to be shared
    And I go to the ext dashboard page
    When I create a folder outline with "Folder1"
    And I navigate to "Documents"
    And I expand the folders ""
    And I click folder-context-icon on the "Folder1" grid row
    And I click x-menu-item "Edit Folder"
    And I click x-tab-strip-text "Sharing"
    And I check "Shared - Accessible to the audience specified below"
    And I select the following in the audience panel:
      | name          | type |
      | Atticus Finch | User |
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I sign out

    When I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    Then I should see "Bartleby Scrivener" in grid row 2
    When I expand the folders "Bartleby"
    Then I should see "Folder1" in grid row 3

  Scenario Outline: Create a range of shared folders with inherited sharing
    When I create shares "<shares>" shared with "atticus@example.com"
    And I sign out
    And I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    Then I should see "Bartleby Scrivener" in grid row 2
    When I expand the folders "Bartleby"
    And I expand the folders "<expand>"
    Then I should see the grid items in this order "<order>"

    Examples:
      | shares                               | expand             | order                                                |
      | Share1 Share2                        |                    | Bartleby>2 Share1>3 Share2>4                         |
      | Share1>Sub1 Sub1>SubSub1 Share2>Sub2 | Share1 Sub1 Share2 | Bartleby>2 Share1>3 Sub1>4 SubSub1>5 Share2>6 Sub2>7 |

  Scenario: Create a shared subfolder without a shared parent
    When I create a folder outline with "Folder1>Sub1"
    And I set "Sub1" as "shared" with "atticus@example.com"
    And I sign out
    And I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    Then I should see "Bartleby Scrivener" in grid row 2
    When I expand the folders "Bartleby"
    Then I should see "Sub1" in grid row 3

  Scenario: Create a subfolder and override inherited sharing
    When I create shares "Folder1>Inherited Folder1>NotShared Folder1>Shared NotShared>SubShared" shared with "atticus@example.com"
    And I set "Inherited" as "inherited"
    And I set "NotShared" as "not shared"
    And I set "Shared" as "shared" with "atticus@example.com"
    And I set "SubShared" as "shared" with "atticus@example.com"
    And I sign out
    And I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    Then I should see "Bartleby Scrivener" in grid row 2
    When I expand the folders "Bartleby Folder1"
    Then I should see the grid items in this order "Bartleby>2 Folder1>3 Inherited>4 Shared>5 SubShared>6"
    And I should not see "NotShared"

  Scenario: Create shares with different permissions
    When I create shares "Reader Author Admin" shared with "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""

    When I click folder-context-icon on the "Author" grid row
    And I click x-menu-item "Edit Folder"
    And I click x-tab-strip-text "Permissions"
    And I select "Author" from ext combo "Atticus Finch"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away

    When I click folder-context-icon on the "Admin" grid row
    And I click x-menu-item "Edit Folder"
    And I click x-tab-strip-text "Permissions"
    And I select "Admin" from ext combo "Atticus Finch"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away

    When I sign out
    And I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders "Bartleby"
    Then I should see the grid items in this order "Bartleby>2 Reader>3 Author>4 Admin>5"

    When I select the "Reader" grid row
    Then ext inlineLink "Create New Folder" should be hidden
    And ext inlineLink "Upload New File" should be hidden
    And ext inlineLink "Edit Folder" should be hidden
    And ext inlineLink "Delete Folder" should be hidden

    When I select the "Author" grid row
    Then ext inlineLink "Create New Folder" should be hidden
    And ext inlineLink "Upload New File" should be visible
    And ext inlineLink "Edit Folder" should be hidden
    And ext inlineLink "Delete Folder" should be hidden

    When I select the "Admin" grid row
    Then ext inlineLink "Create New Folder" should be visible
    And ext inlineLink "Upload New File" should be visible
    And ext inlineLink "Edit Folder" should be visible
    And ext inlineLink "Delete Folder" should be visible



