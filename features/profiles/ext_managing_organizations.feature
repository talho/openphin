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
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Public | Potter County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
      | Bob Smith       | bob.smith@example.com    | SuperAdmin  | Texas    |
    When delayed jobs are processed

  Scenario: Adding a user to an organization as a SuperAdmin
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "bob.smith@example.com"
    When I navigate to the ext dashboard page
    When I edit the user profile for "Jane Smith"
    Then I should see "Organizations"
    When I request the org "DSHS" in the OrgsControl
    Then I should see the following within ".org-item":
      | DSHS |
    And I press "Apply Changes"
    Then I should see the following within ".org-item":
      | DSHS |

  Scenario: Adding a user to an organization as a user
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "jane.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Jane Smith > Manage Organizations"
    And I wait for the "Loading..." mask to go away
    Then I should see "Organizations"
    When I press "Request Organization"
    And I select "DSHS" from ext combo "Organization:"
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
    And I click inlineLink "Approve"
    Then I should see "Jane Smith is now a member of DSHS"

    And I am logged in as "jane.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Jane Smith > Manage Organizations"
    Then I should see "Organizations"
    Then I should see the following within ".org-item":
      | DSHS |

  Scenario: Adding a user to an organization as a user who maliciously posts an approver id
    Given the following entities exist:
      | Organization | DSHS |
    And I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I press "Jane Smith"
    And I follow "My Account"
    Then I should see "Organizations"
    And I press "Request Organization"
    When I select "DSHS - National Organization" from ext combo "Organization:"
    And I maliciously post an approver id
    And I press "Add"
    And I press "Apply Changes"
    #Then I should be specifically on the user profile page for "jane.smith@example.com"
    And I should see "Profile information saved."
    And I should see "Organizations"
    And the "org-pending" class selector should contain "waiting for approval"
    And "bob.smith@example.com" should receive the email:
      | subject       | Request submitted for organization membership in DSHS |
      | body contains | DSHS |

  Scenario: Removing a user from an organization as an admin
    Given the following entities exist:
      | Organization | DSHS |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And I am logged in as "bob.smith@example.com"
    When I navigate to the ext dashboard page
    When I edit the user profile for "Jane Smith"
    Then I should see "Organizations"
    And I should see "DSHS" within ".org-item"
    When I remove the org "DSHS" from EditProfile
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
    Then I should see "You do not have permission to carry out this action."
    And "jane.smith@example.com" should not receive an email
    And "bob.smith@example.com" should not receive an email
