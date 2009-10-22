Feature: Creating document channels
  In order to push documents to groups of people while keeping documents current
  As a user
  I should be able to create a document channel that other users can subscribe to

  Background:
    Given the following administrators exist:
      | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"

  Scenario: Creating a new channel
    When I go to the Documents page
    And I follow "New Channel"
    And I fill in "Name" with "Discovery"
    And I press "Create"
    
    Then I should see "Successfully created the channel"
    And I should see "Discovery"
  
  Scenario: Adding other owners of a channel
  Scenario: Adding a document to a channel
  Scenario: Inviting users to a channel
  Scenario: Ignoring a channel sent to a user by another user
  Scenario: Removing document from channel
  Scenario: User copying a document out of channel
  Scenario: Deleting a channel
  