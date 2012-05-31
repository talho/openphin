@ext
Feature: Forum checking as a user
  
  I want to be able see the forums I'm allowed to see
  As a user
  I want my forum interactions to work correctly
  
  Background:
    When I prepare for user forum tests
    
  Scenario: Ensure New Forum, Edit Forum, Manage Moderators do not appear
    When I should not have ".forum-manage[forum_name='ILI Tracking']" within "td"
    And I should not have ".forum-manage[forum_name='ILI Tracking']" within "td"    
    And I should not see "New Forum" within ".x-btn-text"
    
  Scenario: When there are no forums I should not see a New Forum button
    When I am logged in as "chez@example.com"
    And I navigate to "Forums"    
    And I should not see "New Forum" within ".x-btn-text"
    
  Scenario: Ensure people in the audience can view the forum
    Then the forum "ILI Tracking" exists and is visible
  
  Scenario: Ensure people outside of the Audience Can't view the Forum
    Then the forum "Resource Discovery" exists and is not visible