Feature: Application layout should have communications, portal & application toolbars
	As a user
  I want to see applications that are important to me in the portal toolbar and
		functions specific to the application in the application toolbar and
		communications and utility functions in the communication toolbar
	So that I can navigate the OpenPHIN portal with ease

  Background:
	  Given the following users exist:
		  | Martin Fowler      | martin@example.com   | Health Official | Dallas County |
	  And an article exists
	  And an article exists
    And an article exists
    And an article exists
    And an article exists

	Scenario:
    Given I am logged in as "martin@example.com"
		When I go to the dashboard page
		Then I should see the following menu:
			| name | portal_toolbar       |
			| item | HAN                  |
			| item | RollCall             |
			| item | FAQs                 |
	  And I should see the following menu:
			| name | comm_toolbar         |
			| item | Calendar             |
			| item | Chat                 |
			| item | Documents            |
			| item | Links                |
		And I should see 5 "article" sections

				