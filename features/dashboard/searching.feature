Feature: Searching for users
  In order to quickly find people I want to communicate with
  As a logged in user
  I can search
  
  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Jurisdiction | Texas                 |
      | Role         | Public                |
      | approval role         | Health Officer        |
      | Role         | Immunization Director |
      | Role         | HAN Coordinator       |
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County |
    And the following users exist:
  		| John Smith      | john.smith@example.com   | Public | Dallas County |
  		| Jane Smith      | jane.smith@example.com   | Health Officer | Tarrant County |
  		| Sam Body      | sam@example.com   | Health Officer | Dallas County |
  		| Amy Body      | amy@example.com   | Health Officer | Dallas County |
		And delayed jobs are processed
  
  Scenario: Searching for a user
    Given I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I fill in "Search" with "Smith"
    And I press "Go"
    Then I see the following users in the search results
      | John Smith, Jane Smith |
      
  Scenario: Searching for a user as a user with only a public role
    Given I am logged in as "john.smith@example.com"
  
    When I go to the dashboard page
    Then I should not see "Search"
    When I search for "Smith"
    Then I should be on the dashboard page
    And I should see "You are not authorized"