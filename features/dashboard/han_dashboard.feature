Feature: Viewing the dashboard

    Background:
        Given the following entities exists:
          | Jurisdiction  | Dallas County                               |
          | Jurisdiction  | Tarrant County                              |
          | Jurisdiction  | Texas                                       |
          | Role          | Public                                      |
          | approval role | Health Officer                              |
          | approval role | Immunization Director                       |
          | approval role | Health Alert and Communications Coordinator |
        And the role "Health Alert and Communications Coordinator" is an alerter
        And Texas is the parent jurisdiction of:
          | Dallas County | Tarrant County |
        And Dallas County has the following administrators:
          | Bob Jones      | admin1@dallascounty.com      |
          | Quincy Jones   | admin2@dallascounty.com   |
        And Tarrant County has the following administrators:
          | TarrantCounty Admin  | admin@tarrantcounty.com      |
        And Texas has the following administrators:
          | Zach Dennis   | admin@texas.com      |

    Scenario: Dashboard should show the unapproved role requests
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
    And "john.smith@example.com" has requested to be a "Health Alert and Communications Coordinator" for "Dallas County"
    When I go to the user account roles page
    Then I should see 1 pending role request

    Scenario: Dashboard should show only the panels each user has access to
    
    Scenario: Dashboard should show the user navigation
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
    When I go to the han page
    Then I should see a "Sign Out" link
    And I should not see a "Send an Alert" link
    And I should not see a "View Role" link
    And I should not see a "View Pending Requests" link
    And I should not see a "Alert Log and Reporting" link
    And I should not see a "View Profile" link

    Scenario: Dashboard should show the alerter navigation
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
    And "admin1@texas.com" has approved the "Health Alert and Communications Coordinator" role in "Dallas County" for "john.smith@example.com"
    And I am logged in as "john.smith@example.com"
    When I go to the han page
    Then I should see a "Sign Out" link
    And I should see a "Send an Alert" link
    And I should not see a "View Role" link
    And I should not see a "View Pending Requests" link
    And I should see a "Alert Log and Reporting" link
    And I should not see a "View Profile" link

    Scenario: Dashboard should show the admin navigation
    And I am logged in as "admin1@dallascounty.com"
    When I go to the han page
    Then I should see a "Sign Out" link
    And I should not see a "Send an Alert" link
    And I should not see a "View Role" link
    And I should not see a "Alert Log and Reporting" link
    And I should not see a "View Profile" link
 
    Scenario: Dashboard should show the admin alerter navigation
    And "admin1@texas.com" has approved the "Health Alert and Communications Coordinator" role in "Dallas County" for "admin1@dallascounty.com"
    And I am logged in as "admin1@dallascounty.com"
    When I go to the han page
    Then I should see a "Sign Out" link
    And I should see a "Send an Alert" link
    And I should not see a "View Role" link
    And I should see a "Alert Log and Reporting" link
    And I should not see a "View Profile" link
    