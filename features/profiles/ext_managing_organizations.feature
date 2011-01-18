Feature: Editing user profiles
In order to update contact information
as a user
I should be able to edit my profile

  Background:
    Given the following entities exists:
      | Organization | Red Cross      |
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Texas          |
      | Role         | Health Officer |
      | System role  | Superadmin     |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Public | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
      | Bob Smith       | bob.smith@example.com    | Superadmin  | Texas    |
    When delayed jobs are processed

  Scenario: Adding a user to an organization as a SuperAdmin
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "bob.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Users > Edit Users"
    And I fill in "Name" with "Jane"
    And I press "Search"

    Then I should see the following within ".x-grid3-row":
      | Jane Smith |
    When I click x-grid3-row "Jane Smith"
    And I press "Edit User"
    Then I should see "Organizations"
    When I press "Add organization"
    And I select "DSHS" from ext combo "rq[org]"
    And I press "Add"
    Then I should see the following within ".org-item":
      | DSHS |
    And I press "Apply Changes"
    Then I should see the following within ".org-item":
      | DSHS |

  Scenario: Adding a user to an organization as a user
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "jane.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Organizations"
    Then I should see "Organizations"
    When I press "Add organization"
    And I select "DSHS" from ext combo "rq[org]"
    And I press "Add"
    Then I should see the following within ".org-item":
      | DSHS | needs to be saved |
    When I press "Apply Changes"
    Then I should see the following within ".org-item":
      | DSHS | waiting for approval |
    And I should see "Profile information saved"
    And "bob.smith@example.com" should receive the email:
      | subject       | Request submitted for organization membership in DSHS |
      | body contains | DSHS |

    Given I am logged in as "bob.smith@example.com"
    When I click the organization membership request approval link in the email for "jane.smith@example.com"
    And I follow "Approve"
    Then I should see "Jane Smith is now a member of DSHS"

    And I am logged in as "jane.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "My Account > Manage Organizations"
    Then I should see "Organizations"
    Then I should see the following within ".org-item":
      | DSHS |

  Scenario: Adding a user to an organization as a user who maliciously posts an approver id
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I follow "My Account"
    Then I should see "Organizations"
    When I select "DSHS" from "Organization Membership Request"
    And I maliciously post an approver id
    And I press "Save"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And the "organizations" class selector should not contain "DSHS"
    And I should see "Your request to be a member of DSHS has been sent to an administrator for approval"
    And "bob.smith@example.com" should receive the email:
      | subject       | Request submitted for organization membership in DSHS |
      | body contains | DSHS |

  Scenario: Removing a user from an organization as an admin
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "bob.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Admin > Manage Users > Edit Users"
    And I fill in "Name" with "Jane"
    And I press "Search"
    Then I should see the following within ".x-grid3-row":
      | Jane Smith |
    When I click x-grid3-row "Jane Smith"
    And I press "Edit User"
    Then I should see "Organizations"
    And I should see "DSHS" within ".org-item"
    When I click org-title "DSHS"
    And I press "Remove organization"
    And I press "Apply Changes"
    When delayed jobs are processed
    Then I should see "Organizations"
    And I should not see "DSHS"

  Scenario: Removing a user from an organization as that user
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "jane.smith@example.com"
    When I specifically go to the user edit profile page for "jane.smith@example.com"
    Then I should see "Organizations"
    And I should see "DSHS"
    When I will confirm on next step
    And I follow "Remove Organization Membership" within ".organizations"
    Then I should be specifically on the user edit profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And I should not see "DSHS" within ".organizations"
    And "jane.smith@example.com" should not receive an email

  Scenario: Removing a user from an organization as another user
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "jill.smith@example.com"
    When I specifically go to the user edit profile page for "jane.smith@example.com"
    Then I should see "Organizations"
    And I should see "DSHS"
    When I will confirm on next step
    And I maliciously attempt to remove "jane.smith@example.com" from "DSHS"
    Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Organizations"
    And I should see "DSHS" within ".organizations"
    And "jane.smith@example.com" should not receive an email
    And "bob.smith@example.com" should not receive an email
