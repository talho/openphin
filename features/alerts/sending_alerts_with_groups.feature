Feature: Sending alerts using groups
	In order to conveniently send alerts to predetermined groups of people
	As an alerter
	I want to select a predefined group from the alert audience screen

Background:
	Given the following entities exist:
		| Role          | Epidemiologist                              |
		| Role          | Health Officer                              |
		| Role          | BT Coordinator                              |
    | Role          | Health Alert and Communications Coordinator |
    | Jurisdiction  | Potter County                               |
  And a system role named "Admin"
  And the role "Health Alert and Communications Coordinator" is an alerter
	And the role "Health Officer" is an alerter
	And the role "Epidemiologist" is an alerter
  And the following users exist:
    | John Smith  | john.smith@example.com | Health Alert and Communications Coordinator | Tarrant County |
    | John Smith  | john.smith@example.com | Admin                                       | Tarrant County |
		| Jane Smith  | jane.smith@example.com | Health Alert and Communications Coordinator | Tarrant County |
		| Bob Smith   | bob.smith@example.com  | Health Alert and Communications Coordinator | Texas          |
    | Leroy Smith | leroy@example.com      | Epidemiologist                              | Potter County  |
  And "john.smith@example.com" should have the "Admin" role in "Tarrant County"
	And the following groups for "john.smith@example.com" exist:
	  | G1 | Tarrant County | Health Officer |  | Personal     |                |
	  | G2 | Texas          | Epidemiologist |  | Global       |                |
	  | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

	Scenario: Owner should see all his groups
		Given I am logged in as "john.smith@example.com"
		When I go to the new alert page
		Then I should see "G1" as a groups option
		And I should see "G2" as a groups option
		And I should see "G3" as a groups option

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    When I go to the new alert page
    Then I should see "G2" as a groups option
    And I should see "G3" as a groups option

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    When I go to the new alert page
    Then I should see "G2" as a groups option

  Scenario: Saving an alert with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    When I go to the new alert page
    And I fill out the alert form with:
      | Jurisdictions         | Potter County                                |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Groups                | G2                                           |
      | Severity              | Minor                                        |
      | Status                | Test                                         |
      | Communication methods | E-mail                                       |
    And I press "Preview Message"
    Then I should see a preview of the message
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And the following users should receive the alert email:
      | People | bob.smith@example.com, leroy@example.com |

  Scenario: Sending an alert to only a group with no other audience specified
    Given I am logged in as "john.smith@example.com"
    When I go to the new alert page
    And I fill out the alert form with:
      | Title        | H1N1 SNS push packs to be delivered tomorrow |
      | Groups       | G2                                           |
      | Severity     | Minor                                        |
      | Status       | Test                                         |
      | Communication methods      | E-mail                                       |
    And I press "Preview Message"
    Then I should see a preview of the message
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And the following users should receive the alert email:
      | People | bob.smith@example.com |
