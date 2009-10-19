Feature: Adding documents to document sharing
  In order to share documents to other users
  As a user
  I should be able to add documents to my store

  Background:
    Given I am logged in as a user with an approval role

  Scenario: Viewing documents
    When I click the documents tab
    Then I should see my documents and folders

    When I follow a document link
    Then it should download to my computer
    
  Scenario: Adding a document to private storage
    When I click "Upload Document"
    And I browse to the file
    And I click "Upload"
    Then I should see the document in my root folder

  Scenario: Sending a document to users identified in a group
    Given I have a document in my root folder
    When I select a group
    And I click "Send to group"
    Then members of the group should see the document in their "Inbox" folder

  Scenario: Creating folders to organize documents

  Scenario: Creating nested folders to organize documents

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