Feature: Approving users for roles
  In order to access alerts
  As a user
  I can request roles

  Background: 
    Given the following entities exists:
      | Organization  | Red Cross      |      |
      | Jurisdiction  | Dallas County  |      |
      | Jurisdiction  | Potter County  |      |
      | approval role | Health Officer | phin |
    And the following administrators exist:
      | admin@dallas.gov | Dallas County |
      | admin@potter.gov | Potter County |
    And the following users exist:
      | John Smith | john@example.com | Public | Texas |

  @role_request @index_ext_erb @index_html_erb
  Scenario: Jurisdiction Admin approving role requests in their jurisdiction via View Pending Requests
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    When I navigate to "Admin > Pending Role Requests"
    Then I should see the following within ".pending_role_requests":
      | john@example.com | Health Officer | Dallas | Deny | Approve |
    When I click approve_link "Approve" within "tr.pending_role_requests"
    Then "john@example.com" should have 1 email
    And "john@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    And I should see "John Smith has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"

  @role_request @index_ext_erb @index_html_erb
  Scenario: Jurisdiction Admin approving role requests in their jurisdiction via han dashboard
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Pending Role Requests"
    Then I should see the following within ".pending_role_requests":
      | john@example.com | Health Officer | Dallas | Deny | Approve |
    When I click approve_link "Approve" within "tr.pending_role_requests"
    Then "john@example.com" should have 1 email
    And "john@example.com" should receive the email:
      | subject       | Role assigned    |
      | body contains | You have been assigned the role of Health Officer in Dallas County |
    And I should see "John Smith has been approved for the role Health Officer in Dallas County"
    And "john@example.com" should have the "Health Officer" role in "Dallas County"

  @role_request @index_ext_erb @index_html_erb
  Scenario: Jurisdiction Admin approving role requests outside their jurisdiction via han dashboard
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@potter.gov"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Pending Role Requests"
    Then I should not see "john@example.com"

  @role_request @index_ext_erb @index_html_erb
  Scenario: Jurisdiction Admin denying role requests in their jurisdiction via han dashboard
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    When I log in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    And I navigate to "Admin > Pending Role Requests"
    Then I should see the following within ".pending_role_requests":
      | john@example.com | Health Officer | Dallas | Deny | Approve |
    When I click deny_link "Deny" within "tr.pending_role_requests"
    Then "john@example.com" should receive the email:
      | subject       | Request denied    |
      | body contains | You have been denied for the assignment of Health Officer in Dallas County |
    And I should see "John Smith has been denied for the role Health Officer in Dallas County"
    And I should not see "john@example.com"
    And "john@example.com" should not have the "Health Officer" role in "Dallas County"

  @malicious @role_request @index_ext_erb @index_html_erb
  Scenario: Malicious admin cannot remove role requests the user is not an admin of
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    And I am logged in as "admin@potter.gov"
    When I maliciously post a delete for a role request for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    When I log in as "admin@dallas.gov"
    And I navigate to "Admin > Pending Role Requests"
    Then I should see the following within ".pending_role_requests":
      | john@example.com | Health Officer | Dallas | Deny | Approve |

  @malicious
  Scenario: Malicious admin cannot approve role requests the user is not an admin of
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    And I am logged in as "admin@potter.gov"
    When I maliciously post an approve for a role request for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    And I should be on the dashboard page

  @malicious
  Scenario: Malicious admin cannot deny role requests the user is not an admin of
    Given "john@example.com" has requested to be a "Health Officer" for "Dallas County"
    And I am logged in as "admin@potter.gov"
    When I maliciously post a deny for a role request for "john@example.com"
    Then I should see "This resource does not exist or is not available."
    And I should be on the dashboard page
