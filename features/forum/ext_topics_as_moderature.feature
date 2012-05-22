@ext
Feature: Topic checking as a moderator

  I want to be able to reply, edit, quote, and delete topics and comments
  As a moderator
  I want my topic and comments to work appropriately
  
  Background:
    When I prepare for moderator topic tests
    
  Scenario: I delete a topic
    When I prepare a topic "Resource Discovery" with "Let's find something"    
    And I delete topic "Resource Discovery"
    Then the topic "Resouce Discovery" doesn't exist and is not visible
  
  Scenario: I move a topic
    When I prepare a topic "Resource Discovery" with "Let's find something"
    And I move "Resource Discovery" to "Resource Tracking"    
    When I view the topics in forum "Resource Tracking" as "sawesome@example.com"   
    Then the topic "Resource Discovery" with content "Let's find something" exists and is visible
  
  Scenario: I lock a topic
    When I prepare a topic "Resource Discovery" with "Let's find something"
    And I Locked "Resource Discovery"    
    Then moderators and admins can post users can not
  
  Scenario: I delete someone else's comment
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    When I prepare a topic "Resource Discovery" with "Let's find something"    
    And I reply to "Resource Discovery" with "Woo"    
    When I view the topics in forum "ILI Tracking" as "moderator@example.com"
    And I delete "Woo" from topic "Resource Discovery"
    Then the reply "Woo" to "Resource Discovery" doesn't exist and is not visible
  
  Scenario: I edit someone else's comment
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    When I prepare a topic "Resource Discovery" with "Let's find something"
    And I reply to "Resource Discovery" with "Woo"
    When I view the topics in forum "ILI Tracking" as "moderator@example.com"
    And I select the "Resource Discovery" grid row
    And I edit comment "Woo" to "oooooohhhhhhhh" in topic "Outbreak Tracking"
    Then the reply "oooooohhhhhhhh" to "Resource Discovery" exists and is visible
  
  Scenario: I sticky a topic
    When I view the topics in forum "ILI Tracking" as "moderator@example.com"
    And I prepare a topic "Tracking" with "Let's find something"
    And I prepare a topic "Resources" with "Let's find something"
    And I Sticky "Resources"    
    And I should see the grid items in this order "Resources>1 Tracking>2"
    Then "Resources" has visible topic_pinned icon
  
  Scenario: I create a Subforum
  
  Scenario: I act like a user for a forum I don't moderate
    When I view the topics in forum "Resource Tracking" as "admin@dallas.gov"
    When I prepare a topic "Outbreak Tracking" with "Rash Recently"    
    When I view the topics in forum "Resource Tracking" as "moderator@example.com"    
    Then the correct actions are visible on row "Outbreak Tracking"