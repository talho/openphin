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
    When I go to the HAN
    And I follow "Send an Alert"
    Then I should explicitly not see the "Admin" role as an option

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

    When I go to the HAN
    And I follow "Send an Alert"
    Then I should see "Dallas County" as a from jurisdiction option
    Then I should see "Potter County" as a from jurisdiction option
    Then I should not see "Tarrant County" as a from jurisdiction option
    When I fill out the alert form with:
      | Jurisdiction | Potter County                            |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    
    Then an alert exists with:
      | from_jurisdiction | Potter County |
      | title | H1N1 SNS push packs to be delivered tomorrow |
  
  Scenario: Sending alerts form should not contain unapproved organizations
    Given there is an unapproved Blue Cross Blue Shield organization
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    Then I should not see "Blue Cross Blue Shield" organization as an option

  Scenario: Sending alerts should display Federal jurisdiction as an option
    Given the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Dallas County |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    Then I should see "Federal" as a jurisdictions option

  Scenario: Sending alerts should show "Select all children" link for parent jurisdictions
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am on the new alert page
    Then I should see "Select all children"

  Scenario: Sending alerts with only People in the audience should work
    Given the following entities exist:
      | Jurisdiction | Texas         |
    And the following users exist:
      | John Smith      | john.smith@example.com   | HAN Coordinator  | Texas |
    And the role "HAN Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | People   | Jane Smith                                   |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | People            | Jane Smith |
    And I press "Send"
    Then an alert exists with:
      | from_jurisdiction | Texas                                        |
      | people            | Jane Smith                                   |
      | title             | H1N1 SNS push packs to be delivered tomorrow |



