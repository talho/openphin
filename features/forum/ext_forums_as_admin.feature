@ext
Feature: Forum checking as a admin
  
  In order to manage forums
  As an administrator
  I would like to create, edit, hide, and manage modertors
  
  Background:
    And I prepare for admin forum tests    
    
  Scenario: Create a Forum
    When I open a new forum
    And I enter the new forum data and save    
    Then the forum "Dallas Region Discussion" exists and is visible
  
  Scenario: Edit a Forum
    Given I have the forum "Dallas Region Discussion"
    When I edit forum "Dallas Region Discussion"
    And I enter the edit forum data and save
    Then the forum "Dallas Discussion" exists and is visible
  
  Scenario: Manage Moderators for a Forum
    Given I have the forum "Dallas Discussion"
    When I manage forum "Dallas Discussion"
    And I manage the forum and save
    Then the management of the forum is verified
  
  Scenario: Create a Hidden Forum
    When I navigate to "Forums"
    And I click button "New Forum"
    Then I see the new forum page
    And I create new hidden forum "Hidden Discussion" with the audience
      | name | type |
      | Federal | Jurisdiction |
    #check the hiddeness by logging in as a user in the jurisdiction with no admin
    