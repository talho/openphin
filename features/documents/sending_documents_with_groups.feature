Feature: Sending documents using groups
	In order to conveniently send documents to predetermined groups of people
	As a user
	I want to select a predefined group from the audience screen

Background:
  #Given the following entities exist:
  #	| Approval Role | Epidemiologist |
  #	| Approval Role | Health Officer |
  #	| Approval Role | BT Coordinator |
  #  | Jurisdiction  | Potter County  |
#	And the following users exist:
#		| John Smith | john.smith@example.com | Admin          | Tarrant County |
#		| Jane Smith | jane.smith@example.com | Health Officer | Tarrant County |
#		| Bob Smith  | bob.smith@example.com  | Epidemiologist | Texas          |
#	And "john.smith@example.com" is not public in "Texas"
  #And "jane.smith@example.com" is not public in "Texas"
  #And the following groups for "john.smith@example.com" exist:
#	  | G1 | Tarrant County | Health Officer |  | Personal     |                |
#	  | G2 | Texas          | Epidemiologist |  | Global       |                |
#	  | G3 | Tarrant County | Terrorist      |  | Jurisdiction | Tarrant County |

  #removed tests where-in the display of groups was tested. This is not the place to test the audience panel, but rather only a place to use it - CD

  Scenario: Sending a document with a group selected should include group users as recipients
    #For now, groups have been taken out of the audience until we make audiences recursive s.t. an audience can contain a group.
    Then "A recursive audience, s.t. an audience can contain a group" should be implemented
    #Given I am logged in as "john.smith@example.com"
    #And I have the document "sample.wav" in my inbox
    #When I go to the dashboard page
    #And I follow "Documents"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I follow "Inbox"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I check "sample.wav"
    #And I select "#send" from the documents toolbar
    #Then I wait for the "div#send_document_panel div#edit" element to load
    #And I fill out the document sharing form with:
    #  | Groups | G2 |
    #And I press "Send"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I follow "Inbox"
    #Then I wait for the "#document_progress_panel" element to finish
    #And "bob.smith@example.com" should receive the email:
    #  | subject       | John Smith shared a document with you |
    #  | body contains | To view this document                 |
    #And "john.smith@example.com" should not receive an email
    #And "jane.smith@example.com" should not receive an email
    #And I go to the dashboard page
    #
    #Given I am logged in as "bob.smith@example.com"
    #When I go to the dashboard page
    #And I follow "Documents"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I follow "Inbox"
    #Then I wait for the "#document_progress_panel" element to finish
    #Then I should see "sample.wav"
    #And I go to the dashboard page
    #
    #Given I am logged in as "jane.smith@example.com"
    #When I go to the dashboard page
    #And I follow "Documents"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I follow "Inbox"
    #Then I wait for the "#document_progress_panel" element to finish
    #Then I should not see "sample.wav"
