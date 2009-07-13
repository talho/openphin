Feature: Signing up for an account

  In order to participate in sending and receiving alerts
  As a visitor
  I want to be able to sign up for an account
  
  Background: 
    Given the following entities exists:
      | Organization | Red Cross     |
      | Jurisdiction | Dallas County |
      | Role         | Health Alert & Communications Coordinator  |
      | Language     | English       |

  Scenario: Signing up as a public role
    Given I'm visiting the site
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | apples           |
      | Password confirmation | apples    |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Jurisdiction   | Dallas County    |
      | Preferred language | English      |
    Then I should see "Successfully added your account"
    And I should have the "Public" role
    And I should have the communication device
      | Email | john@example.com | 
    And I should receive an email confirmation at "john@example.com"
    And my account is pending
    
    When I click the confirmation link in the email
    Then I should see "Thanks, you've been confirmed!"
    And my account is active
       
