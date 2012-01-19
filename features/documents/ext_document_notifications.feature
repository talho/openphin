@ext
Feature: Receiving notifications to different events

  In order to be informed with what's going on in documents
  As a user
  I want to receive notifications when certain events happen

  Background:
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin | Dallas County  |
      | Atticus Finch      | atticus@example.com  | Admin | Potter County  |
      | Sybil Carpenter    | sybil@example.com    | Admin | Cameron County |
    And delayed jobs are processed
    And I am logged in as "bartleby@example.com"

  Scenario: Receive notification when a document is downloaded the first time
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "Folder1" performs all notifications
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    When I click documents-folder-item "invitees.csv"
    And I override alert
    And I click inlineLink "Download File"
    Then "bartleby@example.com" should receive the email:
      | subject       | Atticus Finch has downloaded the document invitees.csv. |
      | body contains | The document invitees.csv in folder "Folder1" was accessed by Atticus Finch at |

  Scenario: Don't receive email notification when you download a document you own
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "Folder1" performs all notifications
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    When I click documents-folder-item "invitees.csv"
    And I override alert
    And I click inlineLink "Download File"
    Then "bartleby@example.com" should not receive an email


#TODO: To be implemented
#  Scenario: Don't receive notification when a document is downloaded after the first time
#    Then "Action auditing" should be implemented

  Scenario: Receive notification when a user uploads a document to a shared folder you are a member of
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "Folder1" performs all notifications
    When I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I click inlineLink "Upload New File"
<<<<<<< HEAD
    And I attach the file "spec/fixtures/invitees.csv" to "file"
    And I press "OK"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
=======
    And I attach the file "spec/fixtures/invitees.csv" to "File"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
>>>>>>> rails_2_3_14_upgrade
    Then "atticus@example.com" should receive the email:
      | subject       | A document has been added to the shared folder "Folder1" |
      | body contains | A document "invitees.csv" has been added to the shared folder "Folder1" by Bartleby Scrivener. |
    And "bartleby@example.com" should not receive an email

  Scenario: Receive notification when a user uploads a document to a shared folder you own
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "atticus@example.com" is an "author" for "Folder1"
    And "Folder1" performs all notifications
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I click inlineLink "Upload New File"
<<<<<<< HEAD
    And I attach the file "spec/fixtures/invitees.csv" to "file"
    And I press "OK"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
=======
    And I attach the file "spec/fixtures/invitees.csv" to "File"
    And I press "Save"
>>>>>>> rails_2_3_14_upgrade
    Then "bartleby@example.com" should receive the email:
      | subject       | A document has been added to the shared folder "Folder1" |
      | body contains | A document "invitees.csv" has been added to the shared folder "Folder1" by Atticus Finch. |
    And "atticus@example.com" should not receive an email

  Scenario: Receive notification when a user replaces a document in a shared folder you are a member of
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "Folder1" performs all notifications
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Replace File"
    And I attach the file "spec/fixtures/invitees.csv" to "File"
    And I press "Save"
    Then "atticus@example.com" should receive the email:
      | subject       | The document "invitees.csv" has been updated. |
      | body contains | A document "invitees.csv" in the shared folder "Folder1" has been updated by Bartleby Scrivener. |
    And "bartleby@example.com" should not receive an email

  Scenario: Receive notification when a user replaces a document in a shared folder you own
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "atticus@example.com" is an "author" for "Folder1"
    And "Folder1" performs all notifications
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Replace File"
    And I attach the file "spec/fixtures/invitees.csv" to "File"
    And I press "Save"
    Then "bartleby@example.com" should receive the email:
      | subject       | The document "invitees.csv" has been updated. |
      | body contains | A document "invitees.csv" in the shared folder "Folder1" has been updated by Atticus Finch. |
    And "atticus@example.com" should not receive an email

  Scenario: Receive notification when you have been added to a share
    When I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I press "Add Folder"
    And I fill in "Folder Name" with "Folder1"
    And I check "Notify users when they have been invited to share this folder."
    And I click x-tab-strip-text "Sharing"
    And I choose "Shared - Accessible to the audience specified below"
    And I select the following in the audience panel:
      | name          | type |
      | Atticus Finch | User |
    And I press "Save"
    Then "atticus@example.com" should receive the email:
      | subject       | Bartleby Scrivener has added you to the shared folder "Folder1" |
      | body contains | Bartleby Scrivener has given you access to the shared folder "Folder1" |
    And "bartleby@example.com" should not receive an email

  Scenario: Don't receive notification when another user has been added to a share that you are already a member of
    Given I create shares "Folder1" shared with "atticus@example.com"
    And "Folder1" performs all notifications
    When I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I click folder-context-icon on the "Folder1" grid row
    And I click x-menu-item "Edit Folder"
    And I click x-tab-strip-text "Sharing"
    And I select the following in the audience panel:
      | name            | type |
      | Sybil Carpenter | User |
    And I press "Save"
    Then "sybil@example.com" should receive the email:
      | subject       | Bartleby Scrivener has added you to the shared folder "Folder1" |
      | body contains | Bartleby Scrivener has given you access to the shared folder "Folder1" |     
    Then the following users should not receive any emails
      | emails         | bartleby@example.com, atticus@example.com |