@ext
Feature: Topic checking as an user

  I want to be able to reply, edit, quote, and delete (comments I made) topics and comments
  As an user
  I want my topics to show up appropriately
  
  Background:  
    When I prepare for user topic tests
    
  Scenario: Ensure the user can create a topic
    When I open forum "ILI Tracking"
    And I create topic "Recent Outbreaks" with content "Rash recently"
    Then the topic "Recent Outbreaks" with content "Rash recently" exists and is visible
    
  Scenario: Ensure Delete Topic, Edit Topic, Move Topic, and New Subforum don't appear for a user
    When I prepare a topic "Outbreak Tracking" with "Rash Recently"
    Then the correct actions are visible for owner on row "Outbreak Tracking"
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    Then the correct actions are visible on row "Outbreak Tracking"
    
  Scenario: Ensure that the user can reply to an owned topic
    When I prepare a topic "Outbreak Tracking" with "Rash Recently"
    And I reply to "Outbreak Tracking" with "O really?"
    And the reply "O really?" to "Outbreak Tracking" exists and is visible
  
  Scenario: Ensure that the user can reply to someone else's topic
    When I prepare a topic "Outbreak Tracking" with "Rash Recently"
    When I view the topics in forum "ILI Tracking" as "sawesome@example.com"
    And I reply to "Outbreak Tracking" with "O really?"
    And the reply "O really?" to "Outbreak Tracking" exists and is visible
    
  Scenario: A topic owner can edit the topic
    When I prepare a topic "Outbreak Tracking" with "Rash Recently"
    And I check and edit topic "Outbreak Tracking" to "Outbreaks" with "Rashes recently"