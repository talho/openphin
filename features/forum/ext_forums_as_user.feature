@ext
Feature: Forum checking as a user
  
  I want to be able see the forums I'm allowed to see
  As a user
  I want my forum interactions to work correctly
  
  Background:
    Given the following users exist:
      | Hank Hill | hhill@example.com | User | Dallas County |
    And delayed jobs are processed
    And I am logged in as "hhill@example.com"
    
  Scenario: Ensure New Topic, Edit Forum, Manage Moderators do not appear
    Given I am logged in as "hhill@example.com"
    And I go to "Forums"
    And the "Forums" panel should not have the new_forum button
    And the forum "ILI Tracking" is visible
    And the "ILI Tracking" row should not have the edit_forum icon
    And the "ILI Tracking" row should not have the manage_moderators icon
    
  Scenario: Ensure people outside of the Audience Can't view the Forum
    Given I am logged in as "hhill@example.com"
    And I go to "Forums"
    And the forum "ILI Tracking" is visible
    And the forum "Resource Discovery" is not visible