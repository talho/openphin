Feature: Assigning roles to users for roles
  In order to access alerts
  As a user
  I can request roles

  Background: 
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
    And the following administrators exist:
      | admin@dallas.gov | Dallas County |
      | admin@potter.gov | Potter County |
    And the following users exist:
      | John Smith      | john@example.com   | Public | Dallas County |
      | Jane Doe        | jane@example.com   | Public | Dallas County |
      
  Scenario: Admin can assign roles to users in their jurisdictions
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    And I follow "Assign Role"

    When I fill out the assign roles form with:
      | People | John Smith, Jane Doe |
      | Role | Health Officer |
      | Jurisdiction | Dallas County |
    
    Then "john@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    Then "jane@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    And I should see "john@example.com and jane@example.com have been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"
    And "jane@example.com" should have the "Health Officer" role in "Dallas County"
    
  Scenario: Malicious admin cannot assign roles to users outside their jurisdictions 
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    And I follow "Assign Role"

    When I maliciously post the assign role form with:
      | People | John Smith, Jane Doe |
      | Role | Health Officer |
      | Jurisdiction | Potter County |
    
    Then the following users should not receive any emails
      | emails         | john@example.com, jane@example.com |
    And "john@example.com" should not have the "Health Officer" role in "Potter County"
    And "jane@example.com" should not have the "Health Officer" role in "Potter County"

  Scenario: Role assignment form should not contain jurisdictions the user is not an admin of
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    When I follow "Assign Role"
    Then I should not explicitly see "Potter County" in the "Jurisdiction" dropdown
