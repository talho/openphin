
Feature: User Apps

  So I don't have to contact an administrator to get a new app
  As a user
  I want the ability to add public roles
  
  Background:
    Given microsoft and apple are apps
    And I am logged in as a public user
  
  Scenario: Display existing apps
    Given I have the app "microsoft"
    When I navigate to "Apps > Get More Apps"
    Then I should see "phin" in column "Name" within "my-apps-grid"
    And I should see "microsoft" in column "Name" within "my-apps-grid"
    And I should not see "apple" in column "Name" within "my-apps-grid"
    And I should see "app" in column "Name" within "new-apps-grid"
    And I should not see "microsoft" in column "Name" within "new-apps-grid"
    And I should not see "phin" in column "Name" within "new-apps-grid"
      
  Scenario: Add an app
    When I navigate to "Apps > Get More Apps"
    And I select the "microsoft" grid row within ".new-apps-grid"
    And I press "Add Selected App"
    Then I should see "microsoft" in column "Name" within "my-apps-grid"
    And "me@example.com" should have the "Gamer" role for "Texas"
  