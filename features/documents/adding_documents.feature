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
    When I go to the Documents page
    And I attach the "image/jpeg" file at "spec/fixtures/keith.jpg" to "Upload Document"
    And I select " Rockstars" from "Folder"
    And I press "Upload"
    
    Then I should see "keith.jpg"
    
    When I go to the Documents page
    Then I should not see "keith.jpg"
    
    When I follow "Rockstars"
    Then I should see "keith.jpg"
    
    When I follow "keith.jpg"
    Then I should receive the file:
      | Filename     | keith.jpg  |
      | Content Type | image/jpeg |

  Scenario: Viewing documents
    Given I have the document "keith.jpg" in my root folder
    When I go to the Documents page
    Then I should see "keith.jpg"

    When I follow "keith.jpg"
    Then I should receive the file:
      | Filename     | keith.jpg  |
      | Content Type | image/jpeg |

  Scenario: Creating folders to organize documents
    When I go to the Documents page
    And I fill in "Folder Name" with "Important" 
    And I press "Create"
    Then I should see "Important"
    
    And I fill in "Folder Name" with "Less Important" 
    And I press "Create"
    Then I should see "Less Important"

  Scenario: Creating nested folders to organize documents
    When I go to the Documents page
    And I fill in "Folder Name" with "Everything" 
    And I select "Root" from "Inside"
    And I press "Create"
    Then I should see "Everything"

    And I fill in "Folder Name" with "Some Things"
    And I select " Everything" from "Inside"
    And I press "Create"
    Then I should see "Some Things"

  Scenario: removing a document from sharing

  Scenario: copying a document from another user into personal folder

  Scenario: sharing documents without having an approved role membership