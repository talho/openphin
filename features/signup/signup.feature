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
       
  Scenario: Signing up as a public health professionals
    Given I'm visiting the site
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | apples           |
      | Password confirmation | apples    |
      | First name     | John             |
      | Last name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Organization   | Red Cross        |
      | Jurisdiction   | Dallas County    |
      | Role           | Health Alert & Communications Coordinator |
      | Preferred language | English      |
    Then I should see "Successfully added your account"
    And I should have the "Health Alert & Communications Coordinator" role    
    And the "Dallas County" administrators are notified that "john@example.com" has signed up

    Given I log in as "john@example.com"
    Then I should see "Awaiting Approval"
    
    Given I log in as a "Dallas County" administrator
    When I approve "john@example.com"
    Then I should see "john@example.com has been approved"
    And "john@example.com" should receive an email confirmation
    
    Given I log in as "john@example.com"
    Then I should not see "Awaiting Approval"

   Scenario: Confirming a new account 
    Given There is no account for "john@example.com"
    When I sign up for an account as "john@example.com"
    Then I should receive an email confirmation at "john@example.com"
    And my account is pending
    
    When I click the confirmation link in the email
    Then I should see "Thanks, you've been confirmed!"
    And my account is active

    
    
      