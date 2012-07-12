@signup
Feature: Signing up for an account

  In order to participate in sending and receiving alerts
  As a visitor
  I want to be able to sign up for an account
  
  Background:
    Given an organization named "Red Cross"
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And "Texas" is the root jurisdiction of app "phin"
    And Texas has the following administrators:
      | Bob Dole       | bob.dole@example.com      |
    And Dallas County has the following administrators:
      | Bob Jones      | bob.jones@example.com      |
      | Quincy Jones   | quincy.jones@example.com   |
      | Jonas Brothers | jonas.brothers@example.com |
    And a role named "Health Alert and Communications Coordinator"
    
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
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the communication device
      | Email | john@example.com |

  Scenario: Signing up as a public role in Texas
    When I signup for an account with the following info:
      | Email                 | john@example.com |
      | Password              | Apples1          |
      | Password Confirmation | Apples1          |
      | First Name            | John             |
      | Last Name             | Smith            |
      | Preferred name        | Jonathan Smith   |
      | Home Jurisdiction     | Texas            |
      | Preferred language    | English          |    
    And "john@example.com" should not have the "Public" role in "Dallas County"
    And "john@example.com" should have the "Public" role in "Texas"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
    

  Scenario: Signing up as a public role without required fields should display errors
    When I signup for an account with the following info:
      | Email                 | <blank> |
      | Password              | <blank> |
      | Password Confirmation | <blank> |
      | First Name            | <blank> |
      | Last Name             | <blank> |
      | Preferred name        | <blank> |
      | Home Jurisdiction     | <blank> |
    Then I should see:
      | Email can't be blank                   |
      | Password can't be blank                |
      | First name can't be blank              |
      | Last name can't be blank               |
      | Password does not meet minimum complexity requirements Password must contain at least one upper case letter, one lower case letter, and one digit |
      | Password is too short (minimum is 6 characters) |

  Scenario: Signing up as a public health professionals
    When I signup for an account with the following info:
      | Email                 | john@example.com |
      | Password              | Password1        |
      | Password Confirmation | Password1 |
      | First Name            | John             |
      | Last Name             | Smith            |
      | Preferred name        | Jonathan Smith   |
      | Home Jurisdiction     | Dallas County    |
      | Role                  | Health Alert and Communications Coordinator |
      | Preferred language    | English      | 
    And "john@example.com" should have the "Public" role for "Dallas County"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role request for "Dallas County"

    Then the following users should receive the email:
      | roles         | Dallas County / Admin |
      | subject       | User requesting role Health Alert and Communications Coordinator in Dallas County |
      | body contains | requested assignment |
      | body contains | Jonathan Smith (john@example.com) |
      | body contains | Health Alert and Communications Coordinator |
      | body contains | Dallas County |

    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    Then I should see "waiting for approval"
    
    Given "john@example.com" has been approved for the role "Health Alert and Communications Coordinator"
    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    Then I should not see "waiting for approval"

  Scenario: Signing up as a public health professionals in Texas
    When I signup for an account with the following info:
      | Email                 | john@example.com |
      | Password              | Password1        |
      | Password Confirmation | Password1 |
      | First Name            | John             |
      | Last Name             | Smith            |
      | Preferred name        | Jonathan Smith   |
      | Home Jurisdiction     | Texas    |
      | Role                  | Health Alert and Communications Coordinator |
      | Preferred language    | English      |  
    And "john@example.com" should have the "Public" role for "Texas"
    And "john@example.com" should have the "Health Alert and Communications Coordinator" role request for "Texas"

    Then the following users should receive the email:
      | roles         | Texas / Admin |
      | subject       | User requesting role Health Alert and Communications Coordinator in Texas |
      | body contains | requested assignment |
      | body contains | Jonathan Smith (john@example.com) |
      | body contains | Health Alert and Communications Coordinator |
      | body contains | Texas |
    When I sign out
    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    #And I follow "My Account"
    #And I follow "Request Roles"
    Then I should see "waiting for approval"

    Given "john@example.com" has been approved for the role "Health Alert and Communications Coordinator"
    When I sign out
    When I log in as "john@example.com"
    And I navigate to "Jonathan Smith > Manage Roles"
    Then I should not see "waiting for approval"


  Scenario: User signs up with invalid data
    When I signup for an account with the following info:
      | Email                 | invalidemail    |
      | Password              | Password1       |
      | Password Confirmation | <blank>  |
    Then I should see error messages
