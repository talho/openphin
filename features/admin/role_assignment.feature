Feature: Assigning roles to users for roles
  In order to access alerts
  As a user
  I can request roles

  Background: 
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Role         | Health Officer |
      | Role         | Epidemiologist |
      | System role  | Superadmin     |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And Health Officer is a non public role
    And Epidemiologist is a non public role
    And the following administrators exist:
      | admin@dallas.gov  | Dallas County |
      | admin@state.tx.us | Texas         |
      | admin@potter.gov  | Potter County |
    And the following users exist:
      | John Smith      | john@example.com   | Public | Dallas County |
      | Jane Doe        | jane@example.com   | Public | Dallas County |
      | Bob  Doe        |  bob@example.com   | Public | Potter County |
      | Super  Doe      |  super@example.com | Superadmin | Texas     |

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
	  And "admin@dallas.gov" should not receive an email

  Scenario: Admin can assign roles to users in their jurisdictions when a role request already exists
    Given I am logged in as "admin@state.tx.us"
    And "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    And "jane@example.com" has requested to be a "Health Officer" for "Dallas County"
    And all email has been delivered
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
	  And "admin@dallas.gov" should not receive an email

  Scenario: Admin can assign roles to users in their jurisdictions via the user profile
    Given I am logged in as "admin@dallas.gov"
    And the sphinx daemon is running
    When I go to the dashboard page
    And I follow "Find People"
    When delayed jobs are processed
    When I fill in "Search" with "John"
    And I press "Search"
    And I follow "John Smith"
    And I follow "Edit this Person"

    When I select "Dallas County" from "Jurisdiction"
    And I select "Epidemiologist" from "Role"
    And I press "Save"
    And I should see "Profile information saved."

    Then "john@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Epidemiologist in Dallas County |
    And "john@example.com" should have the "Epidemiologist" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email
	  
  Scenario: Admin can assign roles to users in their jurisdictions via the user profile when a role request already exists
    Given I am logged in as "admin@state.tx.us"
    And the sphinx daemon is running
    And "john@example.com" has requested to be a "Epidemiologist" for "Dallas County"
    And all email has been delivered
    When I go to the dashboard page
    And I follow "Find People"
    When delayed jobs are processed
    When I fill in "Search" with "John"
    And I press "Search"
    And I follow "John Smith"
    And I follow "Edit this Person"

    When I select "Dallas County" from "Jurisdiction"
    And I select "Epidemiologist" from "Role"
    And I press "Save"
    And I should see "Profile information saved."

    Then "john@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Epidemiologist in Dallas County |
    And "john@example.com" should have the "Epidemiologist" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email

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
    Then I should explicitly not see "Potter County" in the "Jurisdiction" dropdown

  Scenario: Role assignment should not occur if no jurisdictation is assigned
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    And I follow "Assign Role"
    When I fill out the assign roles form with:
      | People | John Smith |
      | Role | Health Officer |
    Then "john@example.com" should not receive an email
    And I should not see "john@example.com has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should not have the "Health Officer" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email
    And I should see "No jurisdiction was specified"

  Scenario: Role assignment should not occur if no role is assigned
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    And I follow "Assign Role"
    When I fill out the assign roles form with:
      | People | John Smith |
      | Jurisdiction | Dallas County |
    Then "john@example.com" should not receive an email
    And I should not see "john@example.com has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should not have the "Health Officer" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email
    And I should see "No role was specified"

  Scenario: Role assignment should not occur if no users are assigned
      Given I am logged in as "admin@dallas.gov"
      And I go to the roles requests page for an admin
      And I follow "Assign Role"
      When I fill out the assign roles form with:
        | Role         | Health Officer |
        | Jurisdiction | Dallas County  |
      Then "john@example.com" should not receive an email
      And I should not see "john@example.com has been approved for the role Health Officer in Dallas County"
      And "john@example.com" should not have the "Health Officer" role in "Dallas County"
      And "admin@dallas.gov" should not receive an email
      And I should see "No users were specified"

  Scenario: Malicious admin cannot remove role assignments the user is not an admin of
    Given "admin@dallas.gov" has approved the "Health Officer" role in "Dallas County" for "john@example.com"
    And I am logged in as "admin@potter.gov"
    When I maliciously post a deny for a role assignment for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    And I can't test 'should redirect_to' because of webrat bug
    And I should be on the homepage

  Scenario: Assigning system roles to a user in my jurisdiction
    Given I am logged in as "admin@potter.gov"
    When I edit the profile for "bob@example.com"
    Then I should see "System:Admin" in the role select
    And I select "System:Admin" from "Role"
    And I select "Potter County" from "Jurisdiction"
    And I press "Save"
    Then I should see "System:Admin"

  Scenario: Superadmin can assign system roles to a user in child jurisdiction
    Given I am logged in as "super@example.com"
    When I edit the profile for "bob@example.com"
    Then I should see "System:Admin" in the role select
    And I select "System:Admin" from "Role"
    And I select "Potter County" from "Jurisdiction"
    And I press "Save"
    Then I should see "System:Admin"

  Scenario: Assigning system roles to a user in a child of my jurisdiction
    Given I am logged in as "admin@state.tx.us"
    When I edit the profile for "bob@example.com"
    Then I should see "System:Admin" in the role select
    And I select "System:Admin" from "Role"
    And I select "Potter County" from "Jurisdiction"
    And I press "Save"
    Then I should see "System:Admin"

    