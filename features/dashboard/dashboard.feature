@dashboard
Feature: Dashboard

  In order to display custom content
  As a logged in user
  I can see my dashboard

  Background:
    Given the following entities exist:
      | role         | Admin            |
      | role         | Public           |
      | role         | Medical Director |
      | jurisdiction | Texas            |
      | jurisdiction | Potter County    |

    And Texas is the parent jurisdiction of:
      | Potter County |

    And the following users exist:
      | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
      | Texas MD        | tex.md@example.com       | Medical Director | Texas          |
      | Potter Admin    | pott.admin@example.com   | Admin            | Potter County  |
      | Potter MD       | pott.md@example.com      | Medical Director | Potter County  |
      | Potter Public   | pott.pub@example.com     | Public           | Potter County  |
    And the following dashboard exists:
      | application_default | true                |
      | columns             | 1                   |
      | name                | Application Default |
    And the "Application Default" dashboard has the following portlet:
      | column | 1                                      |
      | xtype  | dashboardhtmlportlet                   |
      | config | {"html": "<h1>Welcome to openPHIN</h1>"} |

  Scenario: Public-only user sees default dashboard
    Given I am logged in as "pott.pub@example.com"
    Then I should see "Welcome to openPHIN"

  Scenario: Jurisdiction users see jurisdictional dashboards
    Given the following dashboard exists:
      | application_default | true           |
      | columns             | 1              |
      | name                | Jurisdictional |
    And the "Jurisdictional" dashboard has the following portlet:
      | column | 1                                                     |
      | xtype  | dashboardhtmlportlet                                  |
      | config | {"html": "<h1>This is a jurisdictional dashboard</h1>"} |
    And the "Jurisdictional" dashboard has the following audience:
      | Dashboard Role | viewer        |
      | Jurisdictions  | Potter County |
    And I am logged in as "pott.pub@example.com"
    Then I should see "This is a jurisdictional dashboard"

  Scenario: User selects a dashboard in profile
    Given the following dashboard exists:
      | columns             | 1              |
      | name                | Jurisdictional |
    And the "Jurisdictional" dashboard has the following portlet:
      | column | 1                                                     |
      | xtype  | dashboardhtmlportlet                                  |
      | config | {"html": "<h1>This is a jurisdictional dashboard</h1>"} |
    And the "Jurisdictional" dashboard has the following audience:
      | Dashboard Role | viewer        |
      | Jurisdictions  | Potter County |
    And I am logged in as "pott.pub@example.com"
    Then I should see "This is a jurisdictional dashboard"
    When I navigate to "Potter Public > Edit My Account"
    And I wait for the "Loading..." mask to go away
    And I select "Application Default" from ext combo "Dashboard"
    And I press "Apply Changes"
    And I wait for the "Saving..." mask to go away
    And I navigate to the ext dashboard page
    Then I should see "Welcome to openPHIN"

  Scenario: Maliciously attempting to view dashboard without appropriate permission
    Given the following dashboard exists:
      | columns             | 1           |
      | name                | No Audience |
    And the "No Audience" dashboard has the following portlet:
      | column | 1                                                 |
      | xtype  | dashboardhtmlportlet                              |
      | config | {"html": "<h1>This dashboard has no audience</h1>"} |
    And I am logged in as "pott.pub@example.com"
    Then I should see "Welcome to openPHIN"
    When I force open the "No Audience" dashboard tab
    Then I should not see "This dashboard has no audience"