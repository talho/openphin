@signup
Feature: Signing up for an account

  In order to participate in sending and receiving alerts
  As a visitor
  I want to be able to sign up for an account
  
  Background:
    Given an organization named Red Cross
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And Texas has the following administrators:
      | Bob Dole       | bob.dole@example.com      |
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   |
      | Jonas Brothers | jonas.brothers@example.com |
    And a role named Public
    And an approval role named Health Alert and Communications Coordinator

  Scenario: Signing up as a public role
    When I signup for an account with the following info:
      | Email                 | john@example.com |
      | Password              | Apples1          |
      | Password Confirmation | Apples1          |
      | First Name            | John             |
      | Last Name             | Smith            |
      | Preferred name        | Jonathan Smith   |
      | Home Jurisdiction     | Dallas County    |
      | Preferred language    | English          |
    Then I should see "Thanks for signing up"
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |

  Scenario: Signing up as a public role in Texas
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | Apples1          |
      | Password Confirmation | Apples1   |
      | First Name     | John             |
      | Last Name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction | Texas        |
      | Preferred language | English      |
    Then I should see "Thanks for signing up"
    And "john@example.com" should not have the "Public" role in "Dallas County"
    And "john@example.com" should have the "Public" role in "Texas"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |

  Scenario: Signing up as a public role but accidentally selecting non-public fields
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | Apples1          |
      | Password Confirmation | Apples1   |
      | First Name     | John             |
      | Last Name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction  | Dallas County    |
      | Preferred language | English      |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Are you a public health professional? | <unchecked> |

    Then I should see "Thanks for signing up!"
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should not have the "Health Alert and Communications Coordinator" role request for "Dallas County"
    

  Scenario: Signing up as a public role without required fields should display errors
    When I signup for an account with the following info:
      | Email         | <blank> |
      | Password       | <blank> |
      | Password Confirmation | <blank> |
      | First Name     | <blank>        |
      | Last Name      | <blank>        |
      | Preferred name | <blank>        |
      | Home Jurisdiction| <blank>      |
    Then I should see:
      | Email can't be blank |
      | Password can't be blank |
      | First name can't be blank |
      | Last name can't be blank |
      | Home Jurisdiction needs to be selected |

  Scenario: Signing up as a public health professionals
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | Password1        |
      | Password Confirmation | Password1 |
      | First Name     | John             |
      | Last Name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction | Dallas County    |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
      | Are you a public health professional? | <checked> |
      | Are you with any of these organizations | Red Cross        |
    Then I should see "Thanks for signing up"
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role request for "Dallas County"

    Given I have confirmed my account for "john@example.com"
    Then the following users should receive the email:
      | roles         | Dallas County / Admin |
      | subject       | User requesting role Health Alert and Communications Coordinator in Dallas County |
      | body contains | requested assignment |
      | body contains | Jonathan Smith (john@example.com) |
      | body contains | Health Alert and Communications Coordinator |
      | body contains | Dallas County |

    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    #And I follow "Jonathan Smith"
    #And I follow "Request Roles"
    Then I should see "waiting for approval"
    
    Given "john@example.com" has been approved for the role "Health Alert and Communications Coordinator"
    When I log in as "john@example.com"
    Then I should not see "waiting for approval"

  Scenario: Signing up as a public health professionals in Texas
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | Password1        |
      | Password Confirmation | Password1 |
      | First Name     | John             |
      | Last Name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction | Texas    |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
      | Are you a public health professional? | <checked> |
    Then I should see "Thanks for signing up"
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |
    And "john@example.com" should have the "Public" role for "Texas"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role request for "Texas"

    Given I have confirmed my account for "john@example.com"
    Then the following users should receive the email:
      | roles         | Texas / Admin |
      | subject       | User requesting role Health Alert and Communications Coordinator in Texas |
      | body contains | requested assignment |
      | body contains | Jonathan Smith (john@example.com) |
      | body contains | Health Alert and Communications Coordinator |
      | body contains | Texas |

    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    #And I follow "My Account"
    #And I follow "Request Roles"
    Then I should see "waiting for approval"

    Given "john@example.com" has been approved for the role "Health Alert and Communications Coordinator"
    When I log in as "john@example.com"
    Then I should not see "waiting for approval"

  Scenario: Signing up should not display system-roles
    Given there is an system only Admin role
    When I go to the sign up page
    And I check "Are you a public health professional?"
    Then I should not see "Admin" in the "What is your primary role in public health or emergency response?" dropdown

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
      | Password       | Password1       |
      | Password Confirmation | <blank>  |
    Then I should see error messages

  Scenario: User tries to log in without confirming email address
    Given "john@example.com" is an unconfirmed user
    When I log in as "john@example.com"
    Then I should see "Your account is unconfirmed"
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for signing up |

  Scenario: Sign up should not occur if no home jurisdictation is specified
    When I signup for an account with the following info:
      | Email          | john@example.com |
      | Password       | Password1        |
      | Password Confirmation | Password1 |
      | First Name     | John             |
      | Last Name      | Smith            |
      | Preferred name | Jonathan Smith   |
      | Home Jurisdiction |               |
      | Are you with any of these organizations | Red Cross        |
      | What is your primary role | Health Alert and Communications Coordinator |
      | Preferred language | English      |
      | Are you a public health professional? | <checked> |
    Then "john@example.com" should not receive an email
    And I should not see "Thanks for signing up"
    And "john@example.com" should not exist
	  And "admin@dallas.gov" should not receive an email
    And I should see "Home Jurisdiction needs to be selected"
