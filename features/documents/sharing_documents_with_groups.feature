Feature: Sharing documents using groups
	In order to conveniently share documents to predetermined groups of people
	As an alerter
	I want to select a predefined group from the alert audience screen

Background:
  Given the following entities exist:
  	| Approval Role | Epidemiologist |
  	| Approval Role | Health Officer |
  	| Approval Role | BT Coordinator |
    | Jurisdiction  | Potter County  |
	And the following users exist:
		| John Smith | john.smith@example.com | Admin          | Tarrant County |
		| Jane Smith | jane.smith@example.com | Health Officer | Tarrant County |
		| Bob Smith  | bob.smith@example.com  | Epidemiologist | Texas          |
	And the role "Admin" is an alerter
	And the role "Health officer" is an alerter
	And the role "Epidemiologist" is an alerter
	And the following groups for "john.smith@example.com" exist:
	  | G1 | Tarrant County | Health Officer |  | Personal     | |
	  | G2 | Texas          | Epidemiologist |  | Global       | |
	  | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

	Scenario: Owner should see all his groups
		Given I am logged in as "john.smith@example.com"
		And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the Documents page
    And I follow "Share"
		Then I should see "G1" as a groups option
		And I should see "G2" as a groups option
		And I should see "G3" as a groups option

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the Documents page
    And I follow "Share"
    Then I should see "G2" as a groups option
    And I should see "G3" as a groups option

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the Documents page
    And I follow "Share"
    Then I should see "G2" as a groups option

  Scenario: Sharing a document with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the Documents page
    And I follow "Share"
    And I fill out the document sharing form with:
      | Jurisdictions | Potter County                                |
      | Groups        | G2                                           |
    And I press "Share"

    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page
    And "bob.smith@example.com" should receive the email:
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |
   
    Given I am logged in as "bob.smith@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"
