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
    | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
    | Texas MD        | tex.md@example.com       | Medical Director | Texas          |
    | Potter Admin    | pott.admin@example.com   | Admin            | Potter County  |
    | Potter MD       | pott.md@example.com      | Medical Director | Potter County  |
    | Potter Public   | pott.pub@example.com     | Public           | Potter County  |

  And delayed jobs are processed

@dashboard
Scenario: Creating default dashboard
  Given I am logged in as "tex.admin@example.com"
  When I navigate to the ext dashboard page
  And I wait for the "Loading PHIN" mask to go away
  Then I should see "Admin Mode"
  When I press "Admin Mode"
  Then I should see "User Mode"
  When I press "Save and Publish"
  Then I should see "You must have at least one portlet added to save this dashboard."
  When I press "OK"
  And I press "Add Portlet"
  And I follow "HTML"
  And I click x-tool-gear ""
  And I fill in the htmleditor "htmlportlet" with "Testing, testing, 1 2 3"
  And I press "OK" within ".html-portlet-window"
  And I press "Save and Publish"
  Then I should see "You must enter a name for this dashboard before continuing"
  When I press "Yes"
  Then I should see "You must enter a name for this dashboard before continuing"
  And I fill in Ext prompt with "test"
  When I press "Yes"
  And I wait for the "Saving and Publishing..." mask to go away
  Then I should not see "You must enter a name for this dashboard before continuing"
  When I navigate to the ext dashboard page
  Then I should see "Testing, testing, 1 2 3"

@dashboard
Scenario: Creating new dashboard
  Given a default dashboard for "tex.admin@example.com"
  And I am logged in as "tex.admin@example.com"
  When I navigate to the ext dashboard page
  And I wait for the "Loading PHIN" mask to go away
  And I press "Admin Mode"
  Then I should see "HTML Portlet"
  When I press "New"
  Then I should not see "HTML Portlet"
  When I press "Save and Publish"
  Then I should see "You must have at least one portlet added to save this dashboard."
  When I press "OK"
  And I press "Add Portlet"
  And I follow "HTML"
  And I click x-tool-gear ""
  And I fill in the htmleditor "htmlportlet" with "Testing, testing, 1 2 3"
  And I press "OK" within ".html-portlet-window"
  And I press "Save and Publish"
  Then I should see "You must enter a name for this dashboard before continuing"
  When I press "Yes"
  Then I should see "You must enter a name for this dashboard before continuing"
  And I fill in Ext prompt with "test"
  When I press "Yes"
  And I wait for the "Saving and Publishing..." mask to go away
  Then I should not see "You must enter a name for this dashboard before continuing"
  When I navigate to the ext dashboard page
  And I press "Admin Mode"
  And I select "test" from ext combo "dashboardlist"

@dashboard
Scenario: Edit existing dashboard

@dashboard
Scenario: Select another dashboard to edit

@dashboard
Scenario: Deleting a dashboard

@dashboard
Scenario: Switching column mode

@dashboard
Scenario: Adding and removing portlets to dashboard

@dashboard
Scenario: Re-ordering portlets on dashboard

@dashboard
Scenario: Adding and editing HTML portlets to dashboard

@dashboard
Scenario: Adding and editing Article portlets to dashboard

@dashboard
Scenario: Adding and editing Blog portlets to dashboard

@dashboard
Scenario: Adding and editing RSS/ATOM portlets to dashboard

@dashboard
Scenario: Switching back to user mode

@dashboard
Scenario: Switching to and from preview mode

@dashboard
Scenario: Switching to and from published mode

@dashboard
Scenario: Saving a dashboard as a draft

@dashboard
Scenario: Saving and publishing a dashboard

@dashboard
Scenario: Giving viewer privilege to dashboard

@dashboard
Scenario: Giving editor privilege to dashboard

@dashboard
Scenario: Giving approver privilege to dashboard

@dashboard
Scenario: Giving publisher privilege to dashboard

@dashboard
Scenario: Giving assigner privilege to dashboard

@dashboard
Scenario: Giving reviewer privilege to dashboard

@dashboard
Scenario: Maliciously attempting to modify dashboard without appropriate permission