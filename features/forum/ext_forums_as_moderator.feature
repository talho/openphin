@ext
Feature: Forum checking as a moderator
  
  I want to be able see the forums I'm allowed to see
  As a moderator
  I want my forum interactions to work correctly
  
  Background:
    When I prepare for moderator forum tests
    
  Scenario: Ensure New Forum, Edit Forum, Manage Moderators do not appear
    When "ILI Tracking" has no visible manage_forum icon
    And "ILI Tracking" has no visible edit_forum icon
    And I should not see "New Forum" within "x-btn-text"    
    
  Scenario: Ensure people outside of the Audience Can't view the Forum
    Then the forum "ILI Tracking" exists and is visible
    Then the forum "Resource Discovery" exists and is not visible