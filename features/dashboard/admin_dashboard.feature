@dashboard
Feature: Dashboard Administration

  In order to create custom content
  As a logged in editor
  I create custom dashboards

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
      | Bartleby Scrivener | bartleby@example.com | Admin      | Texas |
      | Atticus Finch      | atticus@example.com  | SuperAdmin | Texas |

     And the following dashboard exists:
      | application_default | true                |
      | columns             | 1                   |
      | name                | Application Default |
     And the "Application Default" dashboard has the following portlet:
      | column | 1                                      |
      | xtype  | dashboardhtmlportlet                   |
      | config | {html: "<h1>Welcome to openPHIN</h1>"} |
     And delayed jobs are processed

  Scenario: Superadmin editing default dashboard
    Given I am logged in as "atticus@example.com"
    Then I should see "Edit Dashboards"
    When I press "Edit Dashboards"
    Then the "Edit Dashboards" tab should be open
    Then I should see "Welcome to openPHIN" within ".portlet"

  Scenario: Admin cannot edit default dashboard
    Given I am logged in as "bartleby@example.com"
    Then I should see "Edit Dashboards"
    When I press "Edit Dashboards"
    Then the "Edit Dashboards" tab should be open
     And I should not see "Welcome to openPHIN" within ".portlet"

  Scenario: Creating new dashboard
    Given I am logged in as "bartleby@example.com"
    When I press "Edit Dashboards"
     And I press "New"
    Then the "Create New Dashboard" window should be open
    When I fill in "Dashboard Name" with "My Dashboard"
     And I press "Create"
    Then the "My Dashboard" dashboard should exist

  Scenario: Create new dashboard and ensure we're now editing that dashboard
    Given I am logged in as "bartleby@example.com"
    When I press "Edit Dashboards"
     And I press "New"
    When I fill in "Dashboard Name" with "My Dashboard"
     And I press "Create"
    When I press "Add Portlet"
     And I click x-menu-item "HTML"
    Then I should see "HTML Portlet" within ".portlet"
    When I click x-tool-gear ""
     And I fill in the htmleditor "htmlportlet" with "My Dashboard Element"
     And I press "OK"
     And I press "Save"
    Then "My Dashboard" should have a portlet with "My Dashboard Element" in column 1

  Scenario: Select another dashboard to edit
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following portlet:
      | column | 1                                      |
      | xtype  | dashboardhtmlportlet                   |
      | config | {html: "<h1>This is a custom dashboard</h1>"} |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
     And I am logged in as "atticus@example.com"
    When I press "Edit Dashboards"
     And I press "Open"
    Then the "Open Dashboard" window should be open
    When I select the "My Dashboard" grid row
     And I press "Open" within ".cms-open-dash-window"
    Then I should see "This is a custom dashboard" within ".portlet"

  Scenario: Deleting a dashboard
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
      And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
    When I edit the "My Dashboard" dashboard as "atticus@example.com"
     And I press "Delete"
     And I press "Yes"
    Then the "My Dashboard" dashboard should not exist

  Scenario: Cannot delete the application default dashboard
    When I edit a dashboard as "atticus@example.com"
     And I press "Delete"
     And I press "Yes"
    Then I should see "Cannot delete application default dashboard"
     And the "Application Default" dashboard should exist

  Scenario: Switching column mode
    When I edit a dashboard as "atticus@example.com"
     And I press "Columns"
    Then I should see "Columns: 1" within ".x-menu-list"
    When I set cms-column-slider to 3
     And I press "Save"
    Then the "Application Default" dashboard should have 3 columns

  Scenario: Removing portlets from dashboard
    Given the "Application Default" dashboard has the following portlet:
      | column | 1                                         |
      | xtype  | dashboardhtmlportlet                      |
      | config | {html: "<h1>second welcome portlet</h1>"} |
    When I edit a dashboard as "atticus@example.com"
     And I click x-tool-close "" within ".portlet"
     And I press "Save"
    Then "Application Default" should not have a portlet with "Welcome to openPHIN"
     And I click x-tool-close "" within ".portlet"
     And I press "Save"
    Then "Application Default" should not have a portlet with "second welcome portlet"

  Scenario: Re-ordering portlets in a single column on dashboard
    Given the "Application Default" dashboard has the following portlet:
      | column | 1                                         |
      | xtype  | dashboardhtmlportlet                      |
      | config | {html: "<h1>second welcome portlet</h1>"} |
    When I edit a dashboard as "atticus@example.com"
     And I move the "second welcome portlet" portlet to position 0 in column 1
     And I press "Save"
    Then "second welcome portlet" should come before the "Welcome to openPHIN" for the "Application Default" dashboard

  Scenario: Moving portlets to a different column
    Given the "Application Default" dashboard has the following portlet:
      | column | 1                                         |
      | xtype  | dashboardhtmlportlet                      |
      | config | {html: "<h1>second welcome portlet</h1>"} |
    When I edit a dashboard as "atticus@example.com"
     And I press "Columns"
     And I set cms-column-slider to 3
     And I move the "second welcome portlet" portlet to position 0 in column 2
     And I press "Save"
    Then "Application Default" should have a portlet with "second welcome portlet" in column 2

  Scenario: Adding HTML portlet to dashboard
    When I edit a dashboard as "atticus@example.com"
     And I press "Add Portlet"
     And I click x-menu-item "HTML"
     And I click x-tool-gear number 2
     And I fill in the htmleditor "htmlportlet" with "My Dashboard Element"
     And I press "OK"
     And I press "Save"
    Then "Application Default" should have a portlet with "My Dashboard Element" in column 1
    Then "Application Default" should have a portlet with "Welcome to openPHIN" in column 1

  Scenario: Adding multiple HTML portlets to dashboard
    When I edit a dashboard as "atticus@example.com"
     And I press "Columns"
     And I set cms-column-slider to 3
     And I press "Add Portlet"
     And I click x-menu-item "HTML"
     And I click x-tool-gear number 2
     And I fill in the htmleditor "htmlportlet" with "My Dashboard Element"
     And I press "OK"
     And I press "Add Portlet"
     And I click x-menu-item "HTML"
     And I click x-tool-gear number 3
     And I fill in the htmleditor "htmlportlet" with "For Another Column"
     And I press "OK"
     And I press "Add Portlet"
     And I click x-menu-item "HTML"
     And I click x-tool-gear number 4
     And I fill in the htmleditor "htmlportlet" with "For Column 3"
     And I press "OK"
     And I move the "My Dashboard Element" portlet to position 0 in column 1
     And I move the "For Another Column" portlet to position 0 in column 2
     And I move the "For Column 3" portlet to position 0 in column 3
     And I press "Save"
    Then "Application Default" should have a portlet with "My Dashboard Element" in column 1
     And "Application Default" should have a portlet with "Welcome to openPHIN" in column 1
     And "Application Default" should have a portlet with "For Another Column" in column 2
     And "Application Default" should have a portlet with "For Column 3" in column 3
     And "My Dashboard Element" should come before the "Welcome to openPHIN" for the "Application Default" dashboard

  Scenario: Editing HTML portlets
    Given the "Application Default" dashboard has the following portlet:
      | column | 1                                         |
      | xtype  | dashboardhtmlportlet                      |
      | config | {html: "<h1>second welcome portlet</h1>"} |
    When I edit a dashboard as "atticus@example.com"
     And I click x-tool-gear number 2
     And I fill in the htmleditor "htmlportlet" with "editing dashboard element"
     And I press "OK"
     And I press "Save"
    Then "Application Default" should have a portlet with "editing dashboard element" in column 1
     And "Application Default" should have a portlet with "Welcome to openPHIN" in column 1

  Scenario: Switching to and from preview mode
    When I edit a dashboard as "atticus@example.com"
    And I press "Preview"
    Then I should see "HTML Portlet" within ".user-mode"
    When I press "Edit View"
    Then I should see "HTML Portlet" within ".admin-mode"

  Scenario: Giving viewer privilege to dashboard
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
     And the "My Dashboard" dashboard has the following portlet:
      | column | 1                                         |
      | xtype  | dashboardhtmlportlet                      |
      | config | {html: "<h1>other dashboard this is</h1>"} |
    When I edit the "My Dashboard" dashboard as "atticus@example.com"
     And I press "Permissions"
    Then the "Permissions" window should be open
    When I select the following in the audience panel:
      | name               | type |
      | Bartleby Scrivener | User |
     And I press "OK"
     And I press "Save"
    Then "Bartleby Scrivener" should be a "viewer" for the "My Dashboard" dashboard
    When I am logged in as "bartleby@example.com"
    Then I should see "other dashboard this is"
    When I navigate to "Bartleby Scrivener > Edit My Account"
     And I select "My Dashboard" from ext combo "Dashboard"
     And I press "Apply Changes"
     And I wait for the "Saving..." mask to go away
     And I navigate to the ext dashboard page
    Then I should see "other dashboard this is"
    When I press "Edit Dashboards"
     And I press "Open"
    Then I should not see "My Dashboard"

  Scenario: Giving editor privilege to dashboard
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
     And the "My Dashboard" dashboard has the following portlet:
      | column | 1                                          |
      | xtype  | dashboardhtmlportlet                       |
      | config | {html: "<h1>other dashboard this is</h1>"} |
    When I edit the "My Dashboard" dashboard as "atticus@example.com"
     And I press "Permissions"
    Then the "Permissions" window should be open
    When I click x-tab-strip-text "Editors"
    When I select the following in the audience panel within ".cms-audience-editors":
      | name               | type |
      | Bartleby Scrivener | User |
     And I press "OK"
     And I press "Save"
    Then "Bartleby Scrivener" should be a "editor" for the "My Dashboard" dashboard
    When I am logged in as "bartleby@example.com"
    Then I should see "other dashboard this is"
    When I press "Edit Dashboards"
     And I should see "other dashboard this is" within ".portlet"

  Scenario: Setting a default dashboard on another user
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | viewer             |
      | Users          | Bartleby Scrivener |
     And the following dashboard exists:
      | columns             | 1            |
      | name                | Not Bartleby |
     And the "Not Bartleby" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
     And I am logged in as "atticus@example.com"
    When I edit the user profile for "Bartleby Scrivener"
     And I expand the "user[dashboard_id]" combo box
    Then I should not see "Not Bartleby"
    When I click x-combo-list-item "Application Default"
     And I press "Apply Changes"
     And I wait for the "Saving..." mask to go away
     And I am logged in as "bartleby@example.com"
    Then I should see "Welcome to openPHIN"

  Scenario: Set a dashboard as the new application default
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | editor        |
      | Users          | Atticus Finch |
    When I edit the "My Dashboard" dashboard on "atticus@example.com"
     And I check application default in the dashboard permission window
     And I press "Save"
    Then "My Dashboard" should be the default dashboard

  Scenario: Non SuperAdmin should not see "Application Default" checkbox in permission window
    Given the following dashboard exists:
          | columns             | 1            |
          | name                | My Dashboard |
     And the "My Dashboard" dashboard has the following audience:
          | Dashboard Role | editor             |
          | Users          | Bartleby Scrivener |
    When I edit the "My Dashboard" dashboard as "bartleby@example.com"
    Then I should not see the application default option in the permissions window

  Scenario: Maliciously attempting to modify dashboard without appropriate permission
    # And I try to post the server while not logged in
    When I navigate to the ext dashboard page
    And I load ExtJs
    And I maliciously try to create a dashboard
    Then The maliciousness response should contain "TXPhin: sessions/new"
    And I maliciously try to edit a dashboard
    Then The maliciousness response should contain "TXPhin: sessions/new"
    And I maliciously try to delete a dashboard
    Then The maliciousness response should contain "TXPhin: sessions/new"
    # And I try to post the server while logged in as public for an app default dashboard
    Given the following users exist:
      | Abel Magwitch | magwitch@example.com | Public | Texas |
    And I am logged in as "magwitch@example.com"
    And I maliciously try to create a dashboard
    Then The maliciousness response should contain /\"success\":false/
    And I maliciously try to edit a dashboard
    Then The maliciousness response should contain /\"success\":false/
    And I maliciously try to delete a dashboard
    Then The maliciousness response should contain /\"success\":false/
    # And I try to post the server while logged in as public for a dashboard that I can view
    Given the following dashboard exists:
      | columns             | 1            |
      | name                | My Dashboard |
    And the "My Dashboard" dashboard has the following audience:
      | Dashboard Role | viewer        |
      | Users          | Abel Magwitch |
    And I maliciously try to edit the "My Dashboard" dashboard
    Then The maliciousness response should contain /\"success\":false/
    And I maliciously try to delete the "My Dashboard" dashboard
    Then The maliciousness response should contain /\"success\":false/
    # And I try to modify the app default dashboard as Admin (not SuperAdmin)
    Given I am logged in as "bartleby@example.com"
    And I maliciously try to edit the "Application Default" dashboard
    Then The maliciousness response should contain /\"success\":false/
    And I maliciously try to delete the "Application Default" dashboard
    Then The maliciousness response should contain /\"success\":false/
    # And I try to modify a different dashboard as SuperAdmin that I don't have rights to
    Given I am logged in as "atticus@example.com"
    And I maliciously try to edit the "My Dashboard" dashboard
    Then The maliciousness response should contain /\"success\":false/
    And I maliciously try to delete the "My Dashboard" dashboard
    Then The maliciousness response should contain /\"success\":false/