Feature: Alert Templates
In order to facilitate rapid response to an event and give access to alert features from a mobile device
As an alerter
I want to save alert templates for reuse and activate them at a later date


  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And this is implemented

	Scenario: Saving an alert template
    When I go to the Alerts page
    And I follow "New Alert"
    Then I should see "Save as Template"

		When I fill out the alert form with:
				| Title  | The Martians are coming |
				| Message | For more details, keep on reading... |
				| Severity | Severe |
				| Status | Actual |
				| Acknowledge | <unchecked> |
				| Communication methods | E-mail |
				| Sensitive | <checked> |
		And I click the button "Save as Template"
		Then I should see 1 saved alert template

	Scenario: Activating an alert template
		And I have created an alert template with:
				| Title  | The Martians are coming |
				| Message | For more details, keep on reading... |
				| Severity | Severe |
				| Acknowledge | <unchecked> |
				| Communication methods | E-mail |
				| Sensitive | <checked> |

		When I go to the Alerts page
		Then I should see "Alert templates"
		And I should see a link to "The Martians are coming"

		When I click on "The Martians are coming"
		Then I should see the alert form with:
				| Title  | The Martians are coming |
				| Message | For more details, keep on reading... |
				| Severity | Severe |
				| Acknowledge | <unchecked> |
				| Communication methods | E-mail |
				| Sensitive | <unchecked> |

		When I fill in the form with:
        | People | Keith Gaddis |
				| Message | The martians have landed, run for your lives! |
				| Status  | Actual |
		And I click the button "Send Alert"
    Then I should see "Successfully sent the alert"
    And I should be on the logs page
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Severe Health Alert The Martians are coming |
      | body contains | Title: The Martians are coming |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | The martians have landed, run for your lives! |


