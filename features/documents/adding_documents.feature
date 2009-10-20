Feature: Adding documents to document sharing
  In order to share documents to other users
  As a user
  I should be able to add documents to my store

  Background:
    Given the following administrators exist:
      | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    
  Scenario: Adding a document to private storage
    When I go to the Documents page
    And I attach the "image/jpeg" file at "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"
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

  Scenario: Sending a document to users identified in a group
    Given I have the document "keith.jpg" in my root folder
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And the following groups for "admin@dallas.gov" exist:
      | Jane Smith      | jane.smith@example.com   | Public | Dallas County |    
    And the following groups for "admin@dallas.gov" exist:
      | Dallas Group | Dallas County | Health Officer | john.smith@example.com | Jurisdiction | Dallas County |

    When I follow "Share"
    And I select "Dallas Group" from "Group"
    And I press "Send to Group"
    
    Given I am logged in as "john.smith@example.com"
    Then I should see "keith.jpg"

    Given I am logged in as "jane.smith@example.com"
    Then I should not see "keith.jpg"

  Scenario: Receiving documents from other users
    Given another user has sent me a document
    Then I should see the document in my Inbox folder

  Scenario: forwarding documents to another group of recipients
    When I go to the documents page
    And I click on a document
    And I select a group
    And I click "Forward to Group"
    Then members of the group should see the document in their inbox folder

  Scenario: removing a document from sharing

  Scenario: copying a document from another user into personal folder

  Scenario: sharing documents without having an approved role membership