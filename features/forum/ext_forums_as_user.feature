@ext
Feature: Forum checking as a user
  
  I want to be able see the forums I'm allowed to see
  As a user
  I want my forum interactions to work correctly
  
  Background:
    When I prepare for user forum tests
    
  Scenario: Ensure New Forum, Edit Forum, Manage Moderators do not appear
    When "ILI Tracking" has no visible manage_forum icon
    And "ILI Tracking" has no visible edit_forum icon
    And I should not see "New Forum" within "x-btn-text"    
    
  Scenario: Ensure people outside of the Audience Can't view the Forum
    And I go to "Forums"
    And the forum "ILI Tracking" is visible
    And the forum "Resource Discovery" is not visible