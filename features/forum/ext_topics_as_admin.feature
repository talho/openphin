@ext
Feature: Topic checking as an administrator

  I want to be able to reply, edit, quote, and delete topics and comments
  As an administrator
  I want my topic and comments to work appropriately
  
  Background:
    When I prepare for admin topic tests
    
  Scenario: I delete a topic
    And I open forum "ILI Tracking"
    When I prepare a topic "Resource Discovery" with "Let's find something"    
    And I delete topic "Resource Discovery"
    Then the topic "Resouce Discovery" doesn't exist and is not visible
  
  Scenario: I edit a topic I don't own
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    When I prepare a topic "Resource Discovery" with "Let's find something"    
    And I reply to "Resource Discovery" with "Woo"
    When I view the topics in forum "ILI Tracking" as "admin@dallas.gov"
    And I check and edit topic "Resource Discovery" to "Resources" with "Find something!"
    Then the topic "Resources" with content "Find something!" exists and is visible
  
  Scenario: I edit a topic I own
    When I open forum "ILI Tracking"
    And I prepare a topic "Resource Discovery" with "Let's find something"    
    And I check and edit topic "Resource Discovery" to "Resources" with "Find something!"
    Then the topic "Resources" with content "Find something!" exists and is visible
    
  Scenario: I move a topic
    When I open forum "ILI Tracking"
    And I prepare a topic "Resource Discovery" with "Let's find something"
    And I move "Resource Discovery" to "Resource Tracking"    
    When I view the topics in forum "Resource Tracking" as "sawesome@example.com"   
    Then the topic "Resource Discovery" with content "Let's find something" exists and is visible
  
  Scenario: I delete someone else's comment
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    When I prepare a topic "Resource Discovery" with "Let's find something"    
    And I reply to "Resource Discovery" with "Woo"    
    When I view the topics in forum "ILI Tracking" as "admin@dallas.gov"
    And I delete "Woo" from topic "Resource Discovery"
    Then the reply "Woo" to "Resource Discovery" doesn't exist and is not visible
  
  Scenario: I edit someone else's comment
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    When I prepare a topic "Resource Discovery" with "Let's find something"
    And I reply to "Resource Discovery" with "Woo"
    When I view the topics in forum "ILI Tracking" as "admin@dallas.gov"
    And I click ".forum-topic-title[topic_name='Resource Discovery']"
    And I edit comment "Woo" to "oooooohhhhhhhh" in topic "Outbreak Tracking"
    Then the reply "oooooohhhhhhhh" to "Resource Discovery" exists and is visible
    
  Scenario: I sticky a topic
    When I view the topics in forum "Resource Tracking" as "admin@dallas.gov"
    And I prepare a topic "Tracking" with "Let's find something"
    And I prepare a topic "Resources" with "Let's find something"
    And I Sticky "Resources"    
    And I should see the topics in this order "Resources>1 Tracking>2"    
    And I should see "Sticky: Resources" within ".forum-topic-title[topic_name='Resources']"
  
  Scenario: I lock a topic
    When I open forum "ILI Tracking"
    When I prepare a topic "Resource Discovery" with "Let's find something"
    And I Locked "Resource Discovery"    
    Then moderators and admins can post users can not
    
  Scenario: I create a Subforum
    When I open forum "ILI Tracking"
    And I press "New Subforum"
    And I create forum with name "Subforum" and with audience:
      | name          | type          |
      | Dallas County | Jurisdiction  |
    Then the forum "Subforum" exists and is visible
    