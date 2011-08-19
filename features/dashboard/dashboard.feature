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

@dashboard
Scenario: Public-only user sees default dashboard

@dashboard
Scenario: Jurisdiction users see jurisdictional dashboards

@dashboard
Scenario: User sees dashboard based on custom audience

@dashboard
Scenario: Maliciously attempting to view dashboard without appropriate permission