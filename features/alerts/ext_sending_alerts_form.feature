Feature: Sending alerts form

  In order to ensure only accessible information is displayed on the form
  As an admin
  Users should not be able to see certain information on the form

  Scenario: Send alert form should perform client side validation
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I click breadCrumbItem "Audience"
    Then I should have the "Details" breadcrumb selected
    And the following fields should be invalid:
      | Title                 |
      | Jurisdiction          |
      | Communication Methods |

    When I fill in "Title" with "This is a test title to pass validation"
    And I check "E-mail"
    And I check "SMS"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    Then I should have the "Details" breadcrumb selected
    And the following fields should be invalid:
      | Message       |
      | Short Message |

    When I fill in "Message" with "This is a test message to pass validation"
    And I fill in "Short Message" with "This is a test short message to pass validation"
    And I click breadCrumbItem "Audience"
    Then I should have the "Audience" breadcrumb selected

    When I override alert
    And I click breadCrumbItem "Preview"
    Then I should see "Please select at least one user, jurisdiction, role, or group to send this alert to." within the alert box

    When I click breadCrumbItem "Details"
    And I click breadCrumbItem "Preview"
    Then I should see "Please select at least one user, jurisdiction, role, or group to send this alert to." within the alert box
    And I should have the "Audience" breadcrumb selected

    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected
    And I should see "This is a test title to pass validation"

  Scenario: Sending alerts form should not contain system roles
    Given there is an system only Admin role
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    Then the "Send Alert" tab should be open
    When I fill in the following:
      | Title   | This is a test title to pass validation   |
      | Message | This is a test message to pass validation |
    And I check "E-mail"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    Then I should have the "Audience" breadcrumb selected
    When I click x-accordion-hd "Roles"
    Then I should not see "Admin"
    When I press "Sign Out"

  Scenario: User with one or more jurisdictions
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I open ext combo "Jurisdiction"
    Then I should see "Dallas County"
    Then I should see "Potter County"
    Then I should not see "Tarrant County"
    When I fill in the following:
      | Title        | H1N1 SNS push packs to be delivered tomorrow |
      | Message      | H1N1 SNS push packs to be delivered tomorrow |
    And I check "E-mail"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open
    When delayed jobs are processed
    Then an alert exists with:
      | from_jurisdiction | Potter County                                |
      | title             | H1N1 SNS push packs to be delivered tomorrow |

  Scenario: Sending alerts should display Federal jurisdiction as an option
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I fill in the following:
      | Title   | This is a test title to pass validation   |
      | Message | This is a test message to pass validation |
    And I check "E-mail"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    Then I should see "Federal"

  Scenario: Sending alerts should show "Select all children" link for parent jurisdictions
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I fill in the following:
      | Title   | This is a test title to pass validation   |
      | Message | This is a test message to pass validation |
    And I check "E-mail"
    And I select "Texas" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    And I click contextDownArrow ""
    Then I should see "Select All Sub-jurisdictions"
    Then I should see "Select No Sub-jurisdictions"

  Scenario: Sending alerts with only People in the audience should work
    Given the following entities exist:
      | Jurisdiction | Texas         |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Texas         |
      | Jane Smith      | jane.smith@example.com   | Health Officer                               | Potter County |
    When delayed jobs are processed
    Given the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I fill in the following:
      | Title        | H1N1 SNS push packs to be delivered tomorrow |
      | Message      | H1N1 SNS push packs to be delivered tomorrow |
    And I select "Texas" from ext combo "Jurisdiction"
    And I check "E-mail"
    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name       | type | email                  |
      | Jane Smith | User | jane.smith@example.com |

    And I click breadCrumbItem "Preview"
    And I expand ext panel "Audience"
    And I should see the following audience breakdown
      | name       | type      |
      | Jane Smith | Recipient |
      | Jane Smith | User      |

    And I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open
    
    Then an alert exists with:
      | from_jurisdiction | Texas                                        |
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |

  Scenario: Sending alerts with call down
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    And I select "Potter County" from ext combo "Jurisdiction"
    And I select "Advanced" from ext combo "Acknowledge"
    # add a 3rd, 4th and 5th response box
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I fill in the following:
      | Title              | H1N1 SNS push packs to be delivered tomorrow |
      | Message            | Some body text                               |
      | Alert Response 1   | if you can respond within 15 minutes         |
      | Alert Response 2   | if you can respond within 30 minutes         |
      | Alert Response 3   | if you can respond within 1 hour             |
      | Alert Response 4   | if you can respond within 4 hour             |
      | Alert Response 5   | if you cannot respond                        |
    And I select "Test" from ext combo "Status"
    And I select "Minor" from ext combo "Severity"
    And I select "72 hours" from ext combo "Delivery Time"
    And I check "Phone"

    When I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
    And I click breadCrumbItem "Preview"

    And I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    Then an alert exists with:
      | from_jurisdiction   | Potter County                                |
      | title               | H1N1 SNS push packs to be delivered tomorrow |
      | call_down_messages  | if you can respond within 15 minutes         |
      | call_down_messages  | if you can respond within 30 minutes         |
      | call_down_messages  | if you can respond within 1 hour             |
      | call_down_messages  | if you can respond within 4 hours            |
      | call_down_messages  | if you cannot respond                        |
      | acknowledge         | true                                         |

  Scenario: Sending alerts with non cross jurisdiction
     Given the following entities exists:
       | Jurisdiction | Dallas County  |
       | Jurisdiction | Potter County  |
       | Jurisdiction | Tarrant County |
     And the following users exist:
       | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
       | Jane Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
     And the role "HAN Coordinator" is an alerter
     And I am logged in as "john.smith@example.com"

     When I go to the ext dashboard page
     And I navigate to "HAN > Send an Alert"

     And I fill in the following:
      | Title              | H1N1 SNS push packs to be delivered tomorrow |
      | Message            | Some body text                               |
     And I select "Test" from ext combo "Status"
     And I select "Minor" from ext combo "Severity"
     And I select "72 hours" from ext combo "Delivery Time"
     And I check "Phone"
     And I select "Potter County" from ext combo "Jurisdiction"
     And I select "Normal" from ext combo "Acknowledge"
    
     And I check "Disable Cross-Jurisdictional Alerting"

     When I click breadCrumbItem "Audience"
     And I select the following in the audience panel:
      | name           | type         |
      | Potter County  | Jurisdiction |
     And I click breadCrumbItem "Preview"

     And I press "Send Alert"
     Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
     And the "Send Alert" tab should not be open
    
     Then an alert exists with:
      | from_jurisdiction         | Potter County                                |
      | title                     | H1N1 SNS push packs to be delivered tomorrow |
      | not_cross_jurisdictional  | true                                         |

  Scenario: Sending alerts to Organizations
    Given the following entities exist:
      | Jurisdiction | Texas          |
      | Organization | DSHS           |
    And the following users exist:
    # since we're doing this in the texas space and aren't selecting a jurisdiction, I'm going to use the default han coordinator role here.
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Texas         |
      | Jane Smith      | jane.smith@example.com   | Health Officer                               | Texas         |
    And "jane.smith@example.com" is a member of the organization "DSHS"
    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title              | H1N1 SNS push packs to be delivered tomorrow |
      | Message            | Some body text                               |
    And I select "Texas" from ext combo "Jurisdiction" 
    And I check "Phone"

    When I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name  | type         |
      | DSHS  | Organization |
    And I click breadCrumbItem "Preview"

    And I expand ext panel "Audience"
    And I should see the following audience breakdown
      | name       | type         |
      | DSHS       | Organization |
      | Jane Smith | Recipient    |

    And I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open
    
    Then an alert exists with:
      | from_jurisdiction | Texas                                        |
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |
