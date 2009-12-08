Feature: Sharing documents using groups
	In order to conveniently share documents to predetermined groups of people
	As a user
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
  And "john.smith@example.com" is not public in "Texas"
  And "jane.smith@example.com" is not public in "Texas"
  And the following groups for "john.smith@example.com" exist:
	  | G1 | Tarrant County | Health Officer |  | Personal     |                |
	  | G2 | Texas          | Epidemiologist |  | Global       |                |
	  | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

	Scenario: Owner should see all his groups
		Given I am logged in as "john.smith@example.com"
	  And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I fill in "Rockstars" for "Share Name"
    And I press "Create Share"
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Rockstars"
    And I press "Share"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"
		Then I should see "G1" as a groups option
		And I should see "G2" as a groups option
		And I should see "G3" as a groups option

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I fill in "Rockstars" for "Share Name"
    And I press "Create Share"
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Rockstars"
    And I press "Share"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"
    Then I should see "G2" as a groups option
    And I should see "G3" as a groups option

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I fill in "Rockstars" for "Share Name"
    And I press "Create Share"
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Rockstars"
    And I press "Share"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"
    Then I should see "G2" as a groups option

  Scenario: Sharing a document with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I fill in "Rockstars" for "Share Name"
    And I press "Create Share"
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Rockstars"
    And I press "Share"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"
    And I fill out the document sharing form with:
      | Groups        | G2            |
    And I press "Invite"
    Then I should be redirected to the document viewing panel
    When I follow "Rockstars"
    Then I should see "sample.wav"
    And "bob.smith@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to:      |

    Given I am logged in as "bob.smith@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"
