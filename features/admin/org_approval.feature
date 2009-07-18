@approval
Feature: Approving an organization
In order to increase community involvement
system organization administrators
should be able to manage organization enrollements

 Background:
    Given the following entities exist:
        | Jurisdiction      | Dallas County           |
        | Jurisdiction      | Texas                   |
        | Jurisdiction      | Tarrant County          |
        | Jurisdiction      | Denton County           |
        | Organization Type | Non-Profit Organization |
        | Role              | Public                  |
    And the following organization administrators exist:
        | keith@texashan.org     | Texas      |

  Scenario: approving an organization signup
    Given there is an unapproved Gopher Lovers of America organization
    And I am logged in as "keith@texashan.org"
    When I go to the dashboard page
    Then I should see the organization "Gopher Lovers of America" is awaiting approval

    When I approve the organization "Gopher Lovers of America"
    Then I should not see the organization "Gopher Lovers of America" is awaiting approval
    And "Gopher Lovers of America" contact should receive the following email:
      | subject       | Confirmation of Gopher Lovers of America organization registration    |
      | body contains | Thanks for signing up.  Your users may now begin enrollment.|

Scenario: denying an organization signup
	Given there is an unapproved Furries organization with "furrylover@example.com" as the contact
	And I am logged in as "keith@texashan.org"

	When I deny the organization "Furries"
	Then I should not see the organization "Furries" is awaiting approval
	And "furrylover@example.com" should receive the email:
				| subject       | Organization registration request denied    |
				| body contains | Thanks for your organization request. |
				| body contains | Your request has been denied.         |

