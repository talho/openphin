Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

    Scenario: User is not signed up
      Given no user exists with an email of "email@person.com"
      When I go to the sign in page
      And I sign in as "email@person.com/Password1"
      Then I should see "Bad email or password"
      And I should be signed out

    Scenario: User is not confirmed
      Given I signed up with "email@person.com/Password1"
      When I go to the sign in page
      And I sign in as "email@person.com/Password1"
      Then I should see "Your account is unconfirmed"
      And I should be signed out

   Scenario: User enters wrong password
      Given I am signed up and confirmed as "email@person.com/Password1"
      When I go to the sign in page
      And I sign in as "email@person.com/Wrongpassword1"
      Then I should see "Bad email or password"
      And I should be signed out

   Scenario: User signs in successfully
      Given I am signed up and confirmed as "email@person.com/Password1"
      When I go to the sign in page
      And I sign in as "email@person.com/Password1"
      And I should be signed in

#   Scenario: User signs in and checks "remember me"
#      Given I am signed up and confirmed as "email@person.com/Password1"
#      When I go to the sign in page
#      And I sign in with "remember me" as "email@person.com/Password1"
#      And I should be signed in
#      Then my session should stay active