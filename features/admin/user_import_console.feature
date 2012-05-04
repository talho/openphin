Feature: Importing users from a CSV
  In order to migrate users from an existing HAN/PHIN-like system into OpenPHIN
  As an administrator
  I should be able to use the user importer to create or update users from a normalized csv file

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas |
      | Jurisdiction | Ector |
      | Jurisdiction | Tarrant |
      | Jurisdiction | Region 6/5 South |
    And Texas is the parent jurisdiction of:
      | Ector | Tarrant | Region 6/5 South |

  Scenario: Importing a well-formatted file
    Given the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    andy@example.com,Andy,Contact,Andy Contact,Region 6/5 South,5552345000,5552345001,5552345002
    jay@example.com,Jay,Example,John H. (Jay) Example III,Tarrant,,5552346001,5552346002
    john@example.com,John,User,John User,Ector,5552347000,5552347001,
    bob@example.com,Bob,User,Bob User,Ector,5552348000,,5552348001
    """
    When I import the user file "users.csv" with options "create/update"
    Then "andy@example.com" should have the "Public" role for "Region 6/5 South"
    And "andy@example.com" should have the communication device
      | Email | andy@example.com |
      | Fax   | 5552345001 |
      | Phone | 5552345002 |
      | Phone | 5552345000 |
    And "jay@example.com" should have the "Public" role for "Tarrant"
    And "jay@example.com" should have the communication device
      | Email | jay@example.com |
      | Fax   | 5552346001 |
      | Phone | 5552346002 |
    And "john@example.com" should have the "Public" role for "Ector"
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
    And standard error stream should be empty

  Scenario: Importing users with invalid email addresses
    Given the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    0,Andy,Contact,Andy Contact,Region 6/5 South,5552345000,5552345001,5552345002
    """
    When I import the user file "users.csv" with options "create/update"
    Then no user exists with an email of "0"
    And standard error stream should not be empty

  Scenario: Updating existing users with existing devices
    Given the following users exist:
      | Andy User      | andy@example.com   | Public | Region 6/5 South |
    And andy@example.com has the following devices:
      | Phone | 5552345000 |
    And the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    andy@example.com,Andy,Contact,Andy Contact,Region 6/5 South,5552345000,5552345001,5552345002
    john@example.com,John,Contact,John Contact,Region 6/5 South,5552346000,5552346001,5552346002
    """
    When I import the user file "users.csv" with options "update"
    Then "andy@example.com" should have the communication device
      | Email | andy@example.com |
      | Fax   | 5552345001 |
      | Phone | 5552345002 |
      | Phone | 5552345000 |
    And "john@example.com" should not exist

  Scenario: Importing users without updating
    Given the following users exist:
      | Andy User      | andy@example.com   | Public | Region 6/5 South |
    And andy@example.com has the following devices:
      | Phone | 5552345000 |
    And the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    andy@example.com,Andy,Contact,Andy Contact,Region 6/5 South,5552345000,5552345001,5552345002
    john@example.com,John,Contact,John Contact,Region 6/5 South,5552346000,5552346001,5552346002
    """
    When I import the user file "users.csv" with options "create"
    Then "andy@example.com" should have the communication device
      | Email | andy@example.com |
      | Phone | 5552345000 |
    Then "andy@example.com" should not have the communication device
      | Fax   | 5552345001 |
      | Phone | 5552345002 |
    And "john@example.com" should have the "Public" role for "Region 6/5 South"
    And "john@example.com" should have the communication device
      | Email | john@example.com |
      | Fax | 5552346001 |
      | Phone | 5552346000 |
      | Phone | 5552346002 |

  Scenario: Importing existing users should not change passwords or update existing info
     Given the following users exist:
      | Andy User      | andy@example.com   | Public | Region 6/5 South |
    And "andy@example.com" has the password "Password123"
    And andy@example.com has the following devices:
      | Phone | 5552345000 |
    And the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    andy@example.com,Andy,Contact,Andy Contact,Region 6/5 South,5552345000,5552345001,5552345002
    """
    When I import the user file "users.csv" with options "create/update"
    And I go to the sign in page
    And I sign in with "andy@example.com" and "Password123"
    Then I should be signed in
    When I view the ext profile page for "andy@example.com"
    Then I should see "Andy User"
    And I should not see "Andy Contact"
