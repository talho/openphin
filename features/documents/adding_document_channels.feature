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
    And I follow "New Channel"
    And I fill in "Name" with "Discovery"
    And I press "Create"
    
    Then I should see "Successfully created the channel"
    And I should see "Discovery"
  
  Scenario: Adding other owners of a channel
    Given I created the channel "Project X"
    And I go to the Documents page
  
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should not see "Project X"
    
    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    And I follow "Project X"
    And I follow "Invite" 
    
    When I fill out the channel invitation form with:
      | People | Brandon Keepers |
    And I check "Make these people owners"
      
    And I press "Add"
    Then I should see "Additional owners have been added to this channel"
    
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should see "Project X"
  
  Scenario: Adding a document to a channel
    Given I created the channel "Channel 4"
    And I have the document "sample.wav" in my inbox
    And I follow "Share with channel"
    And I choose "Channel 4"
    And I press "Share"
    
    Then I should see "Document was successfully shared with the channel"
    When I follow "Channel 4"
    Then I should see "sample.wav"
  
  Scenario: Inviting users to a channel
    Given I created the channel "Avian Flus"
    And I go to the Documents page

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should not see "Avian Flus"
  
    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    And I follow "Avian Flus"
    And I follow "Invite" 
  
    When I fill out the channel invitation form with:
      | People | Brandon Keepers |
    And I press "Add"
    Then I should see "Additional users have been added to this channel"
  
    Given I am logged in as "brandon.keepers@example.com"
    When I go to the Documents page
    Then I should see "Avian Flus"
    
  Scenario: Ignoring a channel sent to a user by another user
  Scenario: Removing document from channel
  Scenario: User copying a document out of channel
  Scenario: Deleting a channel
  