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

  Scenario: Admin can upload a user import batch file 
    Given I am logged in as "admin@ector.gov"
    And I go to the user batch page for an admin
    And I show dropdown menus
    And I follow "Batch Users"
    And a jurisdiction named "Ector"
    And I attach the tmp file at "users.csv" to "Upload User CSV file"
    And I press "Upload"
    Then I should see "The user batch has been successfully submitted"

  Scenario: Importing a well-formatted file for users that already exist
    Given the user "John User" with the email "john@example.com" has the role "Public" in "Ector"
    And the user "Bob User" with the email "bob@examplel.com" has the role "Public" in "Ector"
    And the following file "users.csv":
    """
    email,first_name,last_name,display_name,jurisdiction,mobile,fax,phone
    john@example.com,John,User,John User,Ector,5552347000,5552347001,
    bob@example.com,Bob,User,Bob User,Ector,5552348000,,5552348001
    """
    When I import the user file "users.csv" with options "create/update"
    Then I should be on the homepage

  Scenario: Admin can upload a user import batch file with users that already exist
    Given the user "John User" with the email "john@example.com" has the role "Public" in "Ector"
    And I am logged in as "admin@ector.gov"
    And I go to the user batch page for an admin
    And I show dropdown menus
    And I follow "Batch Users"
    And a jurisdiction named "Ector"
    And I attach the tmp file at "users.csv" to "Upload User CSV file"
    And I press "Upload"
    Then I should not see "The user batch was not created"

  Scenario: Reject the attempted upload of a file that is not truly CSV
    Given I am logged in as "admin@ector.gov"
    And I go to the user batch page for an admin
    And a jurisdiction named "Ector"
    And I attach the fixture file at "fixtures/xls-file-named-csv.csv" to "Upload User CSV file"
    And I press "Upload"
    Then I should see "Problem with file"
    And I should see "Please check that it is valid CSV"

  Scenario: Accept a CSV file that is malformed or not a user batch file and receive a rejection email
    Given I am logged in as "admin@ector.gov"
    And I go to the user batch page for an admin
    And a jurisdiction named "Ector"
    And I attach the fixture file at "fixtures/badform.csv" to "Upload User CSV file"
    And I press "Upload"
    When delayed jobs are processed
    Then I should see "The user batch has been successfully submitted."
    And I should see "You will receive an E-Mail if there is a problem processing your request"
    And "admin@ector.gov" should receive the email:
      | subject       | TxPhin:  User batching error |
      | body contains | This user was NOT created |
    
  Scenario: Accept CSV file with extra/incorrect columns but proper format AND email column.
    Given I am logged in as "admin@ector.gov"
    And I go to the user batch page for an admin
    And a jurisdiction named "Ector"
    And I attach the fixture file at "fixtures/wrongcols.csv" to "Upload User CSV file"
    And I press "Upload"
    When delayed jobs are processed
    Then I should see "The user batch has been successfully submitted."
    And I should see "You will receive an E-Mail if there is a problem processing your request"

