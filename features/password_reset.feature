Feature: Password reset
  In order to sign in even if user forgot their password
  A user
  Should be able to reset it

    Scenario: User is not signed up
      Given no user exists with an email of "email@person.com"
      When I request password reset link to be sent to "email@person.com"
      Then I should see "Unknown email"

    Scenario: User is signed up and requests password reset
      Given I signed up with "email@person.com/Password1"
      When I request password reset link to be sent to "email@person.com"
      Then I should see "instructions for changing your password"
      And a password reset message should be sent to "email@person.com"

    Scenario: User is signed up updated his password and types wrong confirmation
      Given I signed up with "email@person.com/Password1"
      When I follow the password reset link sent to "email@person.com"
      And I update my password with "Newpassword1/Wrongconfirmation1"
      Then I should see error messages
      And I should be signed out

    Scenario: User is signed up and updates his password
      Given I signed up with "email@person.com/Password1"
      When I follow the password reset link sent to "email@person.com"
      And I update my password with "Newpassword1/Newpassword1"
      Then I should be signed in
      When I sign out
      Then I should be signed out
      And I sign in as "email@person.com/Newpassword1"
      Then I should be signed in
      
    Scenario: User responses to reset password email
      Given I signed up with "email@person.com/Password1"
      Given I try to change the password of "email@person.com" without token
      Then I should see " The token from your link is missing"

    Scenario: User responses to password reset by linking to edit action without a token
      Given I signed up with "email@person.com/Password1"
      And I try to change the password of "email@person.com" without token      
      Then I should see "The token from your link is missing"
      And I should see "PHIN stands for Public Health Information Network"

    Scenario: User responses to password reset by linking to edit action with a incorrect token
      Given I signed up with "email@person.com/Password1"
      And I follow the password reset link with a damaged token sent to "email@person.com"      
      Then I should see "The token from your link is incorrect"
      And I should see "PHIN stands for Public Health Information Network"
