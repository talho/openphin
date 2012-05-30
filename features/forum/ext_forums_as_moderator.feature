@ext
Feature: Forum checking as a moderator
  
  I want to be able see the forums I'm allowed to see
  As a moderator
  I want my forum interactions to work correctly
  
  Background:
    When I prepare for moderator forum tests
    
  Scenario: Ensure New Forum, Edit Forum, Manage Moderators do not appear
    Then the forum "ILI Tracking" exists and is visible
    When I should not have ".forum-manage[forum_name='ILI Tracking']" within "td"
    And I should not have ".forum-manage[forum_name='ILI Tracking']" within "td"  
    And I should not see "New Forum" within ".x-btn-text"    
    
  Scenario: Ensure moderator outside of the Audience Can't view the Forum
    Then the forum "ILI Tracking" exists and is visible
    Then the forum "Resource Discovery" exists and is not visible