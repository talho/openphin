Feature:

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Organization | DSHS          |
      | Organization | TORCH         |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com      |
    And I am logged in as "joe.smith@example.com"
    Given an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And invitation "DSHS" has the following invitees:
      | Jane Smith | jane.smith@example.com |
      | Bob Smith  | bob.smith@example.com  |
      | John Smith | john.smith@example.com |
      | Bill Smith | bill.smith@example.com |
      | Jim Smith  | jim.smith@example.com  |
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Public" in "Texas"
    And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Potter"
    And the user "Jim Smith" with the email "jim.smith@example.com" has the role "Health Officer" in "Andrews"

  @clear_report_db
  Scenario: Viewing invitation completion status by email
    Given I generate "RecipeInternal::InvitationByProfileUpdatedRecipe" report on "Invitation" named "DSHS"

    When I inspect the generated pdf
    Then I should see "Registrations complete: 60% (3)" in the pdf
    Then I should see "Registrations incomplete: 40% (2)" in the pdf
    Then I should see "0 Invitees Found" in the pdf

    And I should see "Name" in the pdf
    And I should see "Email Address" in the pdf
    And I should see "Pending Role Requests" in the pdf

    And I should not see "Bill Smith" in the pdf
    And I should not see "Bob Smith" in the pdf
    And I should not see "Jane Smith" in the pdf
    And I should not see "Jim Smith" in the pdf
    And I should not see "John Smith" in the pdf
    And I should not see "bill.smith@example.com" in the pdf

    When I inspect the generated csv
    Then I should not see "name" in the csv
    And I should not see "email" in the csv
    And I should not see "is_member" in the csv

    And I should not see "Bill Smith" in the csv
    And I should not see "Bob Smith" in the csv
    And I should not see "Jane Smith" in the csv
    And I should not see "Jim Smith" in the csv
    And I should not see "John Smith" in the csv
