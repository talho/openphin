@ext
Feature: Document Search

  In order to quickly find documents that may be in my document system
  As a user
  I want to be able to search my documents by name

  Background: Create users
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
      | Atticus Finch      | atticus@example.com  | Admin  | Potter County |
    And delayed jobs are processed
    And I am logged in as "bartleby@example.com"

  Scenario: Search for my documents
    Given I create a folder outline with "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And delayed jobs are processed
    When I go to the ext dashboard page
    And I navigate to "Documents"
    And I press "Search"
    Then the "Search for Files" tab should be open
    When I fill in "Search Text" with "inv"
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv"
    When I click documents-folder-item "invitees.csv"
    Then I should see "Owner:Bartleby Scrivener"

  Scenario: Search for shared documents
    Given I create shares "Folder1" shared with "atticus@example.com"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And delayed jobs are processed
    When I sign out
    And I log in as "atticus@example.com"
    And I go to the ext dashboard page
    And I navigate to "Documents"
    And I press "Search"
    And I fill in "Search Text" with "inv"
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv"
    When I click documents-folder-item "invitees.csv"
    Then I should see "Owner:Bartleby Scrivener"

  Scenario: Copying a shared document
    Given I create shares "Folder1" shared with "atticus@example.com"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And delayed jobs are processed
    When I sign out
    And I log in as "atticus@example.com"
    Given I create a folder outline with "AtticusFolder"
    When I go to the ext dashboard page
    And I navigate to "Documents"
    And I press "Search"
    And I fill in "Search Text" with "inv"
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv"
    When I click documents-folder-item "invitees.csv"
    And I click inlineLink "Copy to My Folders"
    And I select "AtticusFolder" from ext combo "Move to"
    And I wait for the "Saving" mask to go away
    And I navigate to "Documents"
    And I wait for the "Loading" mask to go away
    And I expand the folders ""
    And I select the "AtticusFolder" grid row
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv" within ".document-file-icon-view"

  Scenario: Downloading a document
    Given I create a folder outline with "Folder1"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And delayed jobs are processed
    When I go to the ext dashboard page
    And I navigate to "Documents"
    And I press "Search"
    When I fill in "Search Text" with "inv"
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv"
    When I click documents-folder-item "invitees.csv"
    And I will confirm on next step
    And I click inlineLink "Download File"
    Then I should see "Success" within the alert box

  Scenario: Downloading a shared document
    Given I create shares "Folder1" shared with "atticus@example.com"
    And I have uploaded "spec/fixtures/invitees.csv" to "Folder1"
    And delayed jobs are processed
    When I sign out
    And I log in as "atticus@example.com"
    Given I create a folder outline with "AtticusFolder"
    When I go to the ext dashboard page
    And I navigate to "Documents"
    And I press "Search"
    And I fill in "Search Text" with "inv"
    And I wait for the "Loading" mask to go away
    Then I should see "invitees.csv"
    When I click documents-folder-item "invitees.csv"
    And I will confirm on next step
    And I click inlineLink "Download File"
    Then I should see "Success" within the alert box