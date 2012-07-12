
Feature: App Manager
  
  In order to create apps on the fly to properly segment the app
  As an administrator
  I would like to be able to manage all aspects of the apps from the interface
  
  Background:
    Given the following entities exist:
      | Jurisdiction | Texas      |      |
      | Role         | Malcontent | phin |
    When I am logged in as a sysadmin
    When I navigate to "Admin > Manage Apps"
  
  Scenario: Index should show the existing apps
    Then the grid ".app-grid" should contain:
      | Name   |
      | phin   |
      | system |
  
  Scenario: Create an app
    When I create a new app
    Then my new app should exist
  
  Scenario: Edit App Details
    When I edit app "phin"
    And I fill in app details
    Then app "phin" should have my new details
  
  Scenario: Edit Assets
    When I edit app "phin"
    And I add some new assets
    Then app "phin" should have my assets
  
  Scenario: Edit About
    When I edit app "phin"
    And I fill in app about
    Then app "phin" should have my new about
    And I should see my new about
  
  Scenario: Add Role
    When I edit app "phin"
    And I add a role to the app
    Then app "phin" should have my new role
  
  Scenario: Edit Role
    When I edit app "phin"
    And I edit role "Malcontent" for the app
    Then app "phin" should have an updated role
  
  Scenario: Remove Role
    When I edit app "phin"
    And I remove the role "Malcontent" for the app
    Then app "phin" should not have role "Malcontent"
    
  Scenario: Remove App
    Given an app named "bla"
    When I remove app "bla"
    Then app "bla" should not exist