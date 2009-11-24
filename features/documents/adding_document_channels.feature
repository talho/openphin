Feature: Creating document channels
  In order to push documents to groups of people while keeping documents current
  As a user
  I should be able to create a document channel that other users can subscribe to

  Background:
    Given the following entities exists:
      | Jurisdiction  | Dallas County  |
      | Jurisdiction  | Texas          |
      | Approval Role | Health Officer |
      | Approval Role | Epidemiologist |
    And the following users exist:
      | John Smith      | john.smith@example.com      | Health Officer  | Dallas County |
      | Brandon Keepers | brandon.keepers@example.com | Epidemiologist  | Texas         |
    And I am logged in as "john.smith@example.com"
    When I go to the Documents page

  Scenario: Creating a new channel
    And I follow "New Share"
    And I fill in "Name" with "Discovery"
    And I press "Create"
    
    Then I should see "Successfully created the share"
    And I should see "Discovery"
  
  Scenario: Adding other owners of a share
    Given I created the share "Project X"
    And I go to the Documents page
  
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should not see "Project X"
    
    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    And I follow "Project X"
    And I follow "Invite" 
    
    When I fill out the share invitation form with:
      | People | Brandon Keepers |
    And I check "Make these people owners"
      
    And I press "Add"
    Then I should see "Additional owners have been added to this share"
    And "brandon.keepers@example.com" should receive the email:
      | subject       | John Smith added you to a share |
      | body contains | To view this channel |
    
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should see "Project X"
  
  Scenario: Adding a document to a share
    Given I created the share "Channel 4"
    And "brandon.keepers@example.com" has been added to the share "Channel 4"
    And I have the document "sample.wav" in my inbox
    When I go to the Documents page
    And I follow "Share"
    And I check "Channel 4"
    And I press "Share"
    Then I should see "Successfully shared the document"
    And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Channel 4" |
      | body contains | To view this document |
    
    When I follow "Channel 4"
    Then I should see "sample.wav"
  
  Scenario: User copying a document out of share
    Given I have been added to the share "Vacation Photos"
    And a document "keith.jpg" is in the share "Vacation Photos"
    And I have a folder named "Hilarious"
    When I go to the Documents page
    And I follow "Vacation Photos"
    And I follow "Copy"
    And I select " Hilarious" from "Folder"
    And I press "Copy"
    Then I should see "Successfully copied the document"
        
    When I follow "Hilarious"
    Then I should see "keith.jpg"
 
  Scenario: Updating a document in a share
    Given I created the share "Vacation Photos"
    And "brandon.keepers@example.com" has been added to the share "Vacation Photos"
    And a document "keith.jpg" is in the share "Vacation Photos"
    When I go to the Documents page
    And I follow "Vacation Photos"
    And I follow "Edit"
    And I attach the "image/jpeg" file at "spec/fixtures/sample.wav" to "Upload a new version"
    And I press "Update"
    
    And I go to the Documents page
    And I follow "Vacation Photos"
    Then I should not see "keith.jpg"
    Then I should see "sample.wav"
    And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been updated |
      | body contains | To view this document       |
  
  Scenario: Inviting users to a share
    Given I created the share "Avian Flus"
    And I go to the Documents page

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should not see "Avian Flus"
  
    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    And I follow "Avian Flus"
    And I follow "Invite" 
  
    When I fill out the share invitation form with:
      | People | Brandon Keepers |
    And I press "Add"
    Then I should see "Additional users have been added to this share"
    And "brandon.keepers@example.com" should receive the email:
      | subject       | John Smith added you to a share |
      | body contains | To view this channel |
    
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should see "Avian Flus"
    
  Scenario: Unsubscribing from a share
    Given I have been added as owner to the share "Kitty Pictures"
    And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"
    And I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    And I follow "Kitty Pictures"
    And I press "Unsubscribe"
    Then I should see "Successfully unsubscribed from the share"

    When I go to the Documents page
    Then I should not see "Kitty Pictures"
      
    Scenario: Unsubscribing from a share while I am the only owner
      Given I have been added as owner to the share "Kitty Pictures"
      And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"
      When I go to the Documents page
      And I follow "Kitty Pictures"
      And I press "Unsubscribe"
      Then I should see "You can not be removed as owner, since you are the only owner"

      When I go to the Documents page
      Then I should see "Kitty Pictures"

  Scenario: Removing document from share
    Given I created the share "Channel 4"
    And a document "keith.jpg" is in the share "Channel 4"
    
    When I go to the Documents page
    And I follow "Channel 4"
    And I press "Remove from share"
    Then I should see "Successfully removed the document from the share"
    And I should not see "keith.jpg"
  
  Scenario: Deleting a share
    Given I created the share "Avian Flus"
    When I go to the Documents page
    And I follow "Delete Share"
    Then I should be on the show destroy Share page for "Avian Flus"
    And I should see "Avian Flus"
    And I should see "John Smith"
    Then I press "Delete"
    When I go to the Documents page 
    Then I should not see "Avian Flus"
    