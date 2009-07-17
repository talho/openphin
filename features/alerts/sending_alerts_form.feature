Feature: Sending alerts form

  In order to ensure only accessible information is displayed on the form
  As an admin
  Users should not be able to see certain information on the form
  
  Scenario: Sending alerts form should not contain system roles
    Given there is an system only Admin role
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the alerts page
    And I follow "New Alert"
    Then I should not see "Admin" in the "Roles" dropdown

  Scenario: User with one or more jurisdictions
    Given the following entities exists:
      | Jurisdiction | Dallas County  |
      | Jurisdiction | Potter County  |
      | Jurisdiction | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
      | John Smith      | john.smith@example.com   | HAN Coordinator | Potter County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"

    When I go to the alerts page
    And I follow "New Alert"
    Then I should see "Dallas County" in the "From Jurisdiction" dropdown
    And I should see "Potter County" in the "From Jurisdiction" dropdown
    And I should not see "Tarrant County" in the "From Jurisdiction" dropdown
    When I fill out the alert form with:
      | From Jurisdiction | Potter County |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
    Then I see an alert with:
      | From Jurisdiction | Potter County |
      | Title | H1N1 SNS push packs to be delivered tomorrow |
    