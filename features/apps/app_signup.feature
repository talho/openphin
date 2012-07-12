
Feature: App-specific sign up

  To get an app signup on different subdomains
  As a user
  I want to see different data based on the current app
  
  Scenario: Two different app sign up pages should reflect that app
    Given microsoft and apple are apps
    When "apple" is the default app
    And I go to the sign up page
    Then I should see "California"
    And I should not see "Washington"
    When "microsoft" is the default app
    And I go to the sign up page
    Then I should not see "California"
    And I should see "Washington"
  
  Scenario: The list of available roles should have any user roles created but not the public role
    Given microsoft and apple are apps
    When "apple" is the default app
    Then I should see the apple options
  
  Scenario: Signing up with an app and a role should give me the public app role and a request for the other role
    Given microsoft and apple are apps
    When "apple" is the default app
    When I signup for an account with the following info:
      | Email                 | tim@example.com     |
      | Password              | Password1           |
      | Password Confirmation | Password1           |
      | First Name            | Time                |
      | Last Name             | Cook                |
      | Role                  | Turtleneck in Chief |
    And "tim@example.com" should have the "Zombie" role for "California"
    And "tim@example.com" should have the "Turtleneck in Chief" role request for "California"