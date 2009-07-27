Feature: Viewing user profiles
  In order to foster a sense of community
  As a user
  I should be able to view public profiles of other users
  
  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And the following users exist:
  	  | John Smith      | john.smith@example.com   | Public | Dallas County |
  	  | Sam Body        | sam.body@example.com     | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Health Officer" in "Dallas County"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Dallas County"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Potter County"
  	And the user "Sam Body" with the email "sam.body@example.com" has the role "Health Officer" in "Dallas County"
    
  Scenario: Viewing a public profile
    Given sam.body@example.com has a public profile
    When I view the profile page for sam.body@example.com
    Then I can see the profile
    And I should not see the following roles:
      | Health Officer | Dallas County |
    
  Scenario: Viewing a private profile
    Given sam.body@example.com has a private profile
    When I view the profile page for sam.body@example.com
    Then I can not see the profile
  
  Scenario: Viewing my private profile
    Given john.smith@example.com has a private profile
    When I view the profile page for john.smith@example.com
    Then I can see the profile
    And I can see the following roles:
      | Health Officer | Dallas County |
      | Epidemiologist | Dallas County |
      | Epidemiologist | Potter County |