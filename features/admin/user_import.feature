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
    email|first_name|last_name|display_name|jurisdiction|mobile|fax|phone
    john@example.com|John|User|John User|Ector|5552347000|5552347001|
    bob@example.com|Bob|User|Bob User|Ector|5552348000||5552348001
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
    And I follow "Batch Users"
    And a jurisdiction named "Ector"
    And I attach the tmp file at "users.csv" to "Upload User CSV file"
    And I press "Upload"
    Then I should see "The user batch has been successfully submitted"
