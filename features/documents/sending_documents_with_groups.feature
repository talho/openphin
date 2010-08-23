Feature: Sending documents using groups
	In order to conveniently send documents to predetermined groups of people
	As a user
	I want to select a predefined group from the audience screen

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
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#send" from the documents toolbar
    Then I wait for the "div#send_document_panel div#edit" element to load
    Then I should see "G1" as a groups option
    And I should see "G2" as a groups option
    And I should see "G3" as a groups option

  Scenario: Users in same jurisdiction should see jurisdiction-scoped groups
    Given I am logged in as "jane.smith@example.com"
    And I have the document "sample.wav" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#send" from the documents toolbar
    Then I wait for the "div#send_document_panel div#edit" element to load
    Then I should see "G2" as a groups option
    And I should see "G3" as a groups option

  Scenario: Users in another jurisdiction should see only globally-scoped groups
    Given I am logged in as "bob.smith@example.com"
    And I have the document "sample.wav" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#send" from the documents toolbar
    Then I wait for the "div#send_document_panel div#edit" element to load
    And I should see "G2" as a groups option

  Scenario: Sending a document with a group selected should include group users as recipients
    Given I am logged in as "john.smith@example.com"
    And I have the document "sample.wav" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#send" from the documents toolbar
    Then I wait for the "div#send_document_panel div#edit" element to load
    And I fill out the document sharing form with:
      | Groups | G2 |
    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And "bob.smith@example.com" should receive the email:
      | subject       | John Smith shared a document with you |
      | body contains | To view this document                 |
    And "john.smith@example.com" should not receive an email
    And "jane.smith@example.com" should not receive an email
    And I go to the dashboard page

    Given I am logged in as "bob.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"
    And I go to the dashboard page
    
    Given I am logged in as "jane.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should not see "sample.wav"