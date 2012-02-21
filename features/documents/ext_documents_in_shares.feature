@ext
Feature: User documents managed through shares

  In order to share documents with another user
  As a user
  I want to be able to upload documents that another user can see
  and I want that user to be able to upload documents that I can see

  Background: Create Users
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin  | Potter County |
    And delayed jobs are processed
    And I am logged in as "bartleby@example.com"
    And I create shares "Folder1" shared with "atticus@example.com"

  Scenario: Upload a document to a shared folder that another user can see
    When I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I click inlineLink "Upload New File"
    And I upload the file "spec/fixtures/invitees.csv"
    And I press "OK"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I sign out

    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"

    And ext inlineLink "Move Selection" should be hidden
    And ext inlineLink "Replace File" should be hidden
    And ext inlineLink "Delete File" should be hidden

    Then ext inlineLink "Download File" should be visible
    And ext inlineLink "Copy to My Folders" should be visible

  Scenario: Upload a document to a shared folder that another user can modify
    Given "atticus@example.com" is an "author" for "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"
    
    Then ext inlineLink "Upload New File" should be visible
    And ext inlineLink "Replace File" should be visible
    And ext inlineLink "Delete File" should be visible
    And ext inlineLink "Download File" should be visible
    And ext inlineLink "Copy to My Folders" should be visible

  Scenario: Upload a document to a folder that was shared with me and I am an author for
    Given "atticus@example.com" is an "author" for "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I click inlineLink "Upload New File"
    And I upload the file "spec/fixtures/invitees.csv"
    And I press "OK"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I sign out

    And I log in as "bartleby@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

  Scenario: Replace a document through a share
    Given "atticus@example.com" is an "author" for "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Replace File"

    And I attach the file "spec/fixtures/sample.wav" to "File"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see "sample.wav" within ".document-file-icon-view"
    And I should not see "invitees.csv" within ".document-file-icon-view"

    When I sign out
    And I log in as "bartleby@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "sample.wav" within ".document-file-icon-view"

  Scenario: Delete a document in a share
    Given "atticus@example.com" is an "author" for "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Delete File"

    And I press "Yes"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I should not see "invitees.csv" within ".document-file-icon-view"

    When I sign out
    And I log in as "bartleby@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    And I should not see "invitees.csv" within ".document-file-icon-view"

  Scenario: Copy a document from a share to a local folder
    Given "atticus@example.com" is an "author" for "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I sign out
    And I log in as "atticus@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

    And I expand the folders "Bartleby"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Copy to My Folders"
    And I select "My Documents" from ext combo "Move to"
    And I press "Save"

    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

    When I select the "My Documents" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"