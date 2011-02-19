Feature: Sending alerts using groups
	In order to conveniently send alerts to predetermined groups of people
	As an alerter
	I want to select a predefined group from the alert audience screen

  Background:
    Given the following entities exist:
      | Role          | Epidemiologist |
      | Role          | Health Officer |
      | Role          | Admin          |
      | Role          | Health Alert and Communications Coordinator |
      | Role          | BT Coordinator |
      | Jurisdiction  | Potter County  |
    And "Texas" is the parent jurisdiction of:
      | Tarrant County |
      | Potter County  |
    And the role "Admin" is an alerter
    And the role "Health Alert and Communications Coordinator" is an alerter
    And the role "Epidemiologist" is an alerter
    And the following users exist:
      | John Smith  | john.smith@example.com | Admin                                       | Tarrant County |
      | John Smith  | john.smith@example.com | Health Alert and Communications Coordinator | Tarrant County |
      | Jane Smith  | jane.smith@example.com | Health Alert and Communications Coordinator | Tarrant County |
      | Bob Smith   | bob.smith@example.com  | Health Alert and Communications Coordinator | Texas          |
      | Jim Smith   | jim.smith@example.com  | Epidemiologist                              | Texas          |
      | Leroy Smith | leroy@example.com      | Epidemiologist                              | Potter County  |
    And the following groups for "john.smith@example.com" exist:
      | G1 | Tarrant County | Health Officer |  | Personal     |                |
      | G2 | Texas          | Epidemiologist |  | Global       |                |
      | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

  Scenario: Owner should see all his groups
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
                                
    When I fill in the ext alert defaults

    When I click breadCrumbItem "Recipients"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G1"
    And I should see "G2"
    And I should see "G3"

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults

    When I click breadCrumbItem "Recipients"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G2"
    And I should see "G3"
    And I should not see "G1"

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults

    When I click breadCrumbItem "Recipients"
    And I click x-accordion-hd "Groups/Organizations"

    Then I should see "G2"
    And I should not see "G3"
    And I should not see "G1"

  Scenario: Saving an alert with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults
    And I select "Test" from ext combo "Status"

    And I select the following alert audience:
      | name          | type         |
      | Potter County | Jurisdiction |
      | G2            | Group        |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    Then the following users should receive the alert email:
      | People | john.smith@example.com, jane.smith@example.com, bob.smith@example.com, jim.smith@example.com, leroy@example.com |

  Scenario: Sending an alert to only a group with no other audience specified
    Given I am logged in as "john.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults
    And I select "Test" from ext combo "Status"

    And I select the following alert audience:
      | name          | type         |
      | G2            | Group        |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People | john.smith@example.com, jane.smith@example.com, bob.smith@example.com, jim.smith@example.com |
    And "leroy@example.com" should not receive an email