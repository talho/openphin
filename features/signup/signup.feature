@signup
Feature: Signing up for an account

  In order to participate in sending and receiving alerts
  As a visitor
  I want to be able to sign up for an account
  
  Background:
    Given an organization named Red Cross
    And a jurisdiction named Dallas County
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   | 
      | Jonas Brothers | jonas.brothers@example.com |
    And a role named Public
    And an approval role named Health Alert and Communications Coordinator

  Scenario: Signing up as a public role
    When I signup for an account with the following info:
      | Email         | john@example.com |
      | Password       | apples           |
      | Password confirmation | apples    |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | What County    | Dallas County    |
      | Preferred language | English      |
    Then I should see "Thanks for signing up"
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the communication device
      | Email | john@example.com | 
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |

  Scenario: Signing up as a public role without required fields should display errors
    When I signup for an account with the following info:
      | Email         | <blank> |
      | Password       | <blank> |
      | Password confirmation | <blank> |
      | First name     | <blank>        |
      | Last name      | <blank>        |
      | Preferred name | <blank>        |
    Then I should see:
      | Email can't be blank |
      | Password can't be blank |
      | First name can't be blank |
      | Last name can't be blank |
       
  Scenario: Signing up as a public health professionals
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | password         |
      | Password confirmation | password  |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Are you with any of these organizations | Red Cross        |
      | What County    | Dallas County    |
      | What is your primary role within the health department | Health Alert and Communications Coordinator |
      | Preferred language | English      |
    Then I should see "Thanks for signing up"
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role request for "Dallas County"
    
    And the following users should receive the email:
      | roles         | Dallas County / Admin |
      | subject       | User requesting role Health Alert and Communications Coordinator in Dallas County |
      | body contains | requested assignment |
      | body contains | Jonathan Smith (john@example.com) |
      | body contains | Health Alert and Communications Coordinator |
      | body contains | Dallas County |
    
    Given I have confirmed my account for "john@example.com"
    When I log in as "john@example.com"
    Then I should see "Awaiting Approval"
    
    Given "john@example.com" has been approved for the role "Health Alert and Communications Coordinator"
    When I log in as "john@example.com"
    Then I should not see "Awaiting Approval" 
    
  Scenario: Signing up should not display system-roles
    Given there is an system only Admin role
    When I go to the sign up page
    Then I should not see "Admin" in the "What is your primary role within the health department" dropdown

  Scenario: Confirming a new account 
    When I sign up for an account as "john@example.com"
    Then "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |
    When "john@example.com" clicks the confirmation link in the email
    Then I should see "Your account has been confirmed."

  Scenario: User signs up with invalid data
    When I signup for an account with the following info:
      | Email          | invalidemail    |
      | Password       | password        |
      | Password confirmation | <blank>  |
    Then I should see error messages

  Scenario: User tries to log in without confirming email address
    Given "john@example.com" is an unconfirmed user
    When I log in as "john@example.com"
    Then I should see "Your account is unconfirmed"
    And I should see a user confirmation url
    And I should see a link to "Resend confirmation"
    
      