@ext
Feature: Document upload, download, and view

  In order to facilitate the sharing of documents
  As a user
  I would like to be able to upload, download, and view documents

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    And I create a folder outline with "Folder1"
    And I navigate to "Documents"

  Scenario Outline: Upload a document to folder
    When I expand the folders ""
    And I select the "<destination>" grid row
    And I click inlineLink "Upload New File"
    And I attach the file "<file>" to "File"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I select the "<negcheck>" grid row
    And I wait for the "Loading" mask to go away
    Then I should not see "<filename>" within ".document-file-icon-view"
    And I select the "<destination>" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "<filename>" within ".document-file-icon-view"

    Examples:
      | destination  | file                       | filename     | negcheck     |
      | Folder1      | spec/fixtures/invitees.csv | invitees.csv | My Documents |
      | My Documents | spec/fixtures/invitees.csv | invitees.csv | Folder1      |
    
  Scenario Outline: Replace a document
    Given I have uploaded "spec/fixtures/invitees.csv" to "<destination>"
    When I expand the folders ""
    And I select the "<destination>" grid row
    Then I should see "invitees.csv" within ".document-file-icon-view"
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Replace File"
    And I attach the file "spec/fixtures/sample.wav" to "File"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I select the "<destination>" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "sample.wav" within ".document-file-icon-view"

    Examples:
      | destination  |
      | Folder1      |
      | My Documents |

  Scenario: Download a document
    Given I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I expand the folders ""
    And I select the "Folder1" grid row
    And I click documents-folder-item "invitees.csv"
    And I will confirm on next step
    And I click inlineLink "Download File" 
    Then I should see "Success" within the alert box

  Scenario: Move a document
    Given I create a folder outline with "Folder2"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    When I expand the folders ""
    And I select the "Folder1" grid row

    And I click documents-folder-item "invitees.csv"
    And I click inlineLink "Move Selection"
    Then the "Move File" window should be open
    When I select "Folder2" from ext combo "Move to"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should not see "invitees.csv" within ".document-file-icon-view"
    When I select the "Folder2" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Move Selection"
    And I select "My Documents" from ext combo "Move to"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should not see "invitees.csv" within ".document-file-icon-view"
    When I select the "My Documents" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Move Selection"
    And I select "Folder1" from ext combo "Move to"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should not see "invitees.csv" within ".document-file-icon-view"
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

  Scenario Outline: Delete a document
    Given I have uploaded "spec/fixtures/invitees.csv" to "<destination>"
    When I expand the folders ""
    And I select the "<destination>" grid row
    And I wait for the "Loading" mask to go away
    And I click documents-folder-item "invitees.csv"
    And I click inlineLink "Delete File"
    Then the "Delete File" window should be open
    When I press "Yes"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    And I select the "<destination>" grid row
    Then I should not see "invitees.csv" within ".document-file-icon-view"

    Examples:
      | destination  |
      | Folder1      |
      | My Documents |