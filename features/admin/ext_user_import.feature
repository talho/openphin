Feature: Online importing users from a uploaded CSV file
  In order to migrate users from an existing HAN/PHIN-like system into OpenPHIN
  As an admin
  I should be able to use the user importer to create or update users from a normalized csv file

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas |
      | Jurisdiction | Ector |
    And Texas is the parent jurisdiction of:
      | Ector |
      
    Given the following administrators exist:
      | admin@ector.gov | Ector |
    And I am logged in as "admin@ector.gov"

  Scenario: Admin can upload a user import batch file 
    Given the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    john@example.com,John,User,John User,Ector,5552347000,5552347001,
    bob@example.com,Bob,User,Bob User,Ector,5552348000,,5552348001
    """
    When I am logged in as "admin@ector.gov"
    And I navigate to "Admin > Manage Users > Batch Add Users"
    And a jurisdiction named "Ector"
    And I attach the tmp file at "users.csv" to "users[csvfile]"
    Then I should see "Ector"
    When I press "Apply Changes"
    And I wait for 3 seconds
    Then I should not see any errors
    And I should see "The user batch has been successfully submitted"

# add the following 3 scenarios to fulfill story# 4991718
# this is not 100% for all of the columns but if it can track for several, it should for all

  Scenario: Importing a well-formatted file
    Given the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    john@example.com,John,User,John User,Ector,5552347000,5552347001,
    bob@example.com,Bob,User,Bob User,Ector,5552348000,,5552348001
    """
    When I import the user file "users.csv" with options "create/update"

    Then "john@example.com" should have the "Public" role for "Ector"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
      | Phone | 5552347000 |
      
    And "bob@example.com" should have the "Public" role for "Ector"
    And "bob@example.com" should have the communication devices
      | Email | bob@example.com |
      | Phone | 5552348000 |
      | Phone | 5552348001 |
    And "bob@example.com" should not have the communication devices
      | Fax ||

    # add this step to the existing scenario to fulfill story 5144920 
    When delayed jobs are processed
    # add this step to the existing scenario to fulfill story 5144920 
    Then "john@example.com" should receive the email:
      | subject       | TxPhin: Welcome & Password setting                |
      | body contains | You have been signed up by an admin               |
      | body contains | Please follow the link below to set your password |
    #And "john@example.com" should receive the email:
    #  | subject       | TxPhin:  Role assigned             |
    #  | body contains | You have been assigned the role of |

    # add this step to the existing scenario to fulfill story 5144920 
    When delayed jobs are processed
    # add this step to the existing scenario to fulfill story 5144920 
    Then "bob@example.com" should receive the email:
      | subject       | TxPhin: Welcome & Password setting                |
      | body contains | You have been signed up by an admin               |
      | body contains | Please follow the link below to set your password |
    #And "bob@example.com" should receive the email:
    #  | subject       | TxPhin:  Role assigned             |
    #  | body contains | You have been assigned the role of |

    # add this step to the existing scenario to fulfill story 5144993 
    When I sign out
    And I go to the sign in page
    And I sign in as "bob@example.com/Password1"
    Then I should not see "Your account is unconfirmed"
    And I should see "Bad email or password"
    And I should be signed out

    When I follow the password reset link sent to "bob@example.com"
    And I update my password with "Newpassword1/Newpassword1"
    Then I should be signed in

  Scenario: Importing a well-formatted file with email as last column
    Given the following file "users.csv":
    """
    first_name,last_name,display_name,jurisdiction,mobile,fax,phone,email
    John,User,John User,Ector,5552347000,5552347001,,john@example.com
    Bob,User,Bob User,Ector,5552348000,,5552348001,bob@example.com
    """
    When I import the user file "users.csv" with options "create/update"

    Then "john@example.com" should have the "Public" role for "Ector"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
      | Phone | 5552347000 |
      
    And "bob@example.com" should have the "Public" role for "Ector"
    And "bob@example.com" should have the communication devices
      | Email | bob@example.com |
      | Phone | 5552348000 |
      | Phone | 5552348001 |
    And "bob@example.com" should not have the communication devices
      | Fax ||

  Scenario: Importing a well-formatted file with phone,mobile,fax order
    Given the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,phone,mobile,fax
    john@example.com,John,User,John User,Ector,5552347000,,5552347001
    bob@example.com,Bob,User,Bob User,Ector,5552348000,5552348001,
    """
    When I import the user file "users.csv" with options "create/update"

    Then "john@example.com" should have the "Public" role for "Ector"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
      | Phone | 5552347000 |
      | Fax   | 5552347001 |

    And "bob@example.com" should have the "Public" role for "Ector"
    And "bob@example.com" should have the communication devices
      | Email | bob@example.com |
      | Phone | 5552348000 |
      | Phone | 5552348001 |
    And "bob@example.com" should not have the communication devices
      | Fax ||
