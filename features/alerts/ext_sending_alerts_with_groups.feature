Feature: Sending alerts using groups
	In order to conveniently send alerts to predetermined groups of people
	As an alerter
	I want to select a predefined group from the alert audience screen

  Background:
    Given the following entities exist:
      | Role          | Epidemiologist |
      | Role          | Health Officer |
      | Role          | Admin          |
      | Role          | BT Coordinator |
      | Jurisdiction  | Potter County  |
    And the role "Admin" is an alerter
    And the role "Health officer" is an alerter
    And the role "Epidemiologist" is an alerter
    And the following users exist:
      | John Smith | john.smith@example.com | Admin                                       | Tarrant County |
      | John Smith | john.smith@example.com | Health Alert and Communications Coordinator | Tarrant County |
      | Jane Smith | jane.smith@example.com | Health Officer                              | Tarrant County |
      | Bob Smith  | bob.smith@example.com  | Epidemiologist                              | Texas          |
      | Leroy Smith| leroy@example.com      | Epidemiologist                              | Potter County  |
    And the following groups for "john.smith@example.com" exist:
      | G1 | Tarrant County | Health Officer |  | Personal     |                |
      | G2 | Texas          | Epidemiologist |  | Global       |                |
      | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

  Scenario: Owner should see all his groups
    Given I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title   | A title to pass validation   |
      | Message | A message to pass validation |
    And I check "E-mail"
    And I select "Tarrant County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G1"
    And I should see "G2"
    And I should see "G3"

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title   | A title to pass validation   |
      | Message | A message to pass validation |
    And I check "E-mail"
    And I select "Tarrant County" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G2"
    And I should see "G3"
    And I should not see "G1"

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title   | A title to pass validation   |
      | Message | A message to pass validation |
    And I check "E-mail"
    And I select "Texas" from ext combo "Jurisdiction"
    And I click breadCrumbItem "Audience"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G2"
    And I should not see "G3"
    And I should not see "G1"

  Scenario: Saving an alert with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title   | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Long text message...                         |
    And I select "Tarrant County" from ext combo "Jurisdiction"
    And I select "Test" from ext combo "Status"
    And I check "E-mail"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type         |
      | Potter County | Jurisdiction |
      | G2            | Group        |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    And the following users should receive the alert email:
      | People | bob.smith@example.com, leroy@example.com |

  Scenario: Sending an alert to only a group with no other audience specified
    Given I am logged in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    And I fill in the following:
      | Title   | H1N1 SNS push packs to be delivered tomorrow |
      | Message | Long text message...                         |
    And I select "Tarrant County" from ext combo "Jurisdiction"
    And I select "Test" from ext combo "Status"
    And I check "E-mail"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name          | type         |
      | G2            | Group        |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected
    
    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    And the following users should receive the alert email:
      | People | bob.smith@example.com |
