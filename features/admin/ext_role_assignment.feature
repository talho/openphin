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
    When the sphinx daemon is running
    And delayed jobs are processed

  Scenario: Admin can assign roles to users in their jurisdictions via the user profile
    Given I am logged in as "admin@dallas.gov"
    When I go to the ext dashboard page
    And I edit the user profile for "Jane Doe"
    And I add the role "Health Officer" for "Dallas County" from EditProfile
    Then "jane@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    And "jane@example.com" should have the "Health Officer" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email

  Scenario: Admin can assign roles to users in their jurisdictions via the user profile when a role request already exists
    Given I am logged in as "admin@state.tx.us"
    And "jane@example.com" has requested to be a "Health Officer" for "Dallas County"
    And all email has been delivered
    When I go to the ext dashboard page
    And I edit the user profile for "Jane Doe"
    And I add the role "Health Officer" for "Dallas County" from EditProfile
    Then "jane@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    And "jane@example.com" should have the "Health Officer" role in "Dallas County"
	  And "admin@dallas.gov" should not receive an email





  Scenario: Malicious admin cannot assign roles to users outside their jurisdictions
    Given I am logged in as "admin@dallas.gov"
    And I go to the roles requests page for an admin
    And I show dropdown menus
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
    And I show dropdown menus
    And I follow "Assign Role"

    When I maliciously post the assign role form with:
      | People | John Smith, Jane Doe |
      | Role | Health Officer |
      | Jurisdiction | Potter County |

    Then the following users should not receive any emails
      | emails         | john@example.com, jane@example.com |
    And "john@example.com" should not have the "Health Officer" role in "Potter County"
    And "jane@example.com" should not have the "Health Officer" role in "Potter County"

  #Scenario: Role assignment form should not contain jurisdictions the user is not an admin of
  #  Given I am logged in as "admin@dallas.gov"
  #  And I go to the roles requests page for an admin
  #  And I show dropdown menus
  #  When I follow "Assign Role"
  #  Then I should explicitly not see "Potter County" in the "Jurisdiction" dropdown

  Scenario: Malicious admin cannot remove role assignments the user is not an admin of
    Given "admin@dallas.gov" has approved the "Health Officer" role in "Dallas County" for "john@example.com"
    And I am logged in as "admin@potter.gov"
    When I will confirm on next step
    And I maliciously post a deny for a role assignment for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    And I should be on the homepage





  Scenario: Assigning system roles to a user in my jurisdiction
    Given I am logged in as "admin@potter.gov"
    When I go to the ext dashboard page
    And I edit the user profile for "Bob Doe"
    And I add the role "System:Admin" for "Potter County" from EditProfile
    Then "bob@example.com" should have the "Admin" role in "Potter County"
    And I should see "System:Admin" within ".role-item"

  Scenario: Superadmin can assign system roles to a user in child jurisdiction
    Given I am logged in as "super@example.com"
    When I go to the ext dashboard page
    And I edit the user profile for "Bob Doe"
    And I add the role "System:Admin" for "Potter County" from EditProfile
    Then "bob@example.com" should have the "Admin" role in "Potter County"
    And I should see "System:Admin" within ".role-item"

  Scenario: Assigning system roles to a user in a child of my jurisdiction
    Given I am logged in as "admin@state.tx.us"
    When I go to the ext dashboard page
    And I edit the user profile for "Bob Doe"
    And I add the role "System:Admin" for "Potter County" from EditProfile
    Then "bob@example.com" should have the "Admin" role in "Potter County"
    And I should see "System:Admin" within ".role-item"