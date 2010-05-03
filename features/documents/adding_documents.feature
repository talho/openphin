Feature: Adding documents to document sharing
  In order to share documents to other users
  As a user
  I should be able to add documents to my store

  Background:
    Given the following administrators exist:
      | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"

  Scenario: Adding a document to private storage
    Given I have a folder named "Rockstars"
    When I go to the document viewing panel
    And I follow "Rockstars"
    And I attach the "image/jpeg" file at "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"

    Then I should see "keith.jpg"

    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "keith.jpg"

    When I follow "keith.jpg"
    Then I should receive the file:
      | Filename     | keith.jpg  |
      | Content Type | image/jpeg |

  Scenario: Adding a document to a folder that already contains a file by the same name
    Given I have a folder named "Rockstars"
    When I go to the document viewing panel
    And I follow "Rockstars"
    And I attach the "image/jpeg" file at "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"

    When I go to the document viewing panel
    And I follow "Rockstars"
    And I attach the "image/jpeg" file at "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"
    Then I should see "File name is already in use"
    And I should see "keith.jpg"

  Scenario: Viewing documents
    Given I have the document "keith.jpg" in my inbox
    When I go to the document viewing panel
    And I follow "Inbox"
    Then I should see "keith.jpg"

    When I follow "keith.jpg"
    Then I should receive the file:
      | Filename     | keith.jpg  |
      | Content Type | image/jpeg |

  Scenario: Creating folders to organize documents
    When I go to the document viewing panel
    And I fill in "Folder Name" with "Important"
    And I press "Create Folder"
    Then I should see "Important"

    And I fill in "Folder Name" with "Less Important"
    And I press "Create Folder"
    Then I should see "Less Important"

  Scenario: Creating nested folders to organize documents
    When I go to the document viewing panel
    And I fill in "Folder Name" with "Everything"
    And I press "Create Folder"
    Then I should be redirected to the document viewing panel
    And I should see "Everything"

    When I follow "Everything"
    #And I press "Create Folder"
    And I fill in "Folder Name" with "Some Things"
    And I press "Create Folder"
    Then I should be redirected to the document viewing panel
    When I follow "Some Things"
    Then I should see "Contents of Some Things"

  Scenario: Moving a document into a folder
    Given I have a folder named "Rockstars"
    And I have the document "keith.jpg" in my inbox
    When I go to the document viewing panel
    And I follow "Inbox"
    Then I should see "keith.jpg"
    When I check "keith.jpg"
    And I follow "Move/Edit"
    And I select "Rockstars" from "Folder"
    And I press "Move to Folder"

    When I go to the document viewing panel
    Then I should not see "keith.jpg"

    When I follow "Rockstars"
    Then I should see "keith.jpg"

  Scenario: Updating a document
    Given I have the document "keith.jpg" in my inbox
    When I go to the document viewing panel
    And I follow "Inbox"
    And I check "keith.jpg"
    And I follow "Move/Edit"
    And I attach the "image/jpeg" file at "spec/fixtures/sample.wav" to "Upload a new version"
    And I press "Update"

    Then I should not see "keith.jpg"
    Then I should see "sample.wav"
    
    When I go to the document viewing panel
    And I follow "Inbox"
    Then I should not see "keith.jpg"
    Then I should see "sample.wav"

  Scenario: Deleting a document from the inbox
    Given no documents exist
    And I have the document "keith.jpg" in my inbox

    When I go to the document viewing panel
    When I follow "Inbox"
    Then I should see "keith.jpg"

    When I follow "Delete"
    Then I should not see "keith.jpg"
    When I go to the document viewing panel
    When I follow "Inbox"

    Then I should not see "keith.jpg"
    And the file "keith.jpg" in the inbox does not exist

  Scenario: Deleting a document from a folder
    Given no documents exist
    And I have a folder named "Rockstars"
    And I have the document "keith.jpg" in "Rockstars"

    When I go to the document viewing panel
    When I follow "Rockstars"
    Then I should see "keith.jpg"

    When I follow "Delete"
    Then I should not see "keith.jpg"
    When I go to the document viewing panel
    When I follow "Rockstars"

    Then I should not see "keith.jpg"
    And the file "keith.jpg" in folder "Rockstars" does not exist

  Scenario: Deleting a folder with documents
    Given no documents exist
    And I have a folder named "Rockstars"
    And I have the document "keith.jpg" in "Rockstars"

    When I go to the document viewing panel
    When I follow "Rockstars"
    Then I should see "keith.jpg"
    When I go to the document viewing panel
    And I should see "Rockstars" has require confirmation

    When I follow "Delete"
    Then I should not see "keith.jpg"
    And I should be on the document viewing panel
    Then I should not see "Rockstars"

    And I should not see "keith.jpg"
    And the file "keith.jpg" and folder "Rockstars" do not exist
