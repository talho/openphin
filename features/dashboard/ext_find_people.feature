Feature: Find People
  In order to communicate with people via the PHIN
  As a logged in user with a non-public role
  I can quickly find people.

Background:
  Given the following entities exist:
    | role         | Admin            |
    | role         | Medical Director |
    | role         | Public           |
    | jurisdiction | Texas            |
    | jurisdiction | Dallas County    |
    | jurisdiction | Potter County    |

  And Texas is the parent jurisdiction of:
    | Dallas County | Potter County |

  And the following users exist:
    | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
    | Dallas Admin    | dall.admin@example.com   | Admin            | Dallas County  |
    | Dallas MD       | dall.md@example.com      | Medical Director | Dallas County  |
    | Dallas Public   | dall.pub@example.com     | Public           | Dallas County  |
    | Potter Admin    | pott.admin@example.com   | Admin            | Potter County  |
    | Potter MD       | pott.md@example.com      | Medical Director | Potter County  |
    | Potter Public   | pott.pub@example.com     | Public           | Potter County  |

  And pott.admin@example.com has the following information:
    | phone        | 888-123-1111    |
    | mobile_phone | 888-123-3333    |
    | employer     | Potter Genetics |
    | title        | Supervisor      |

  And pott.pub@example.com has the following information:
    | phone        | 777-123-1111    |
    | mobile_phone | 777-123-3333    |
    | employer     | Potter Genetics |
    | title        | Receptionist    |

  And pott.md@example.com has the following information:
    | phone        | 666-123-1111    |
    | mobile_phone | 666-123-3333    |
    | employer     | Potter Genetics |
    | title        | Doctor          |

  And dall.admin@example.com has the following information:
    | phone        | 444-123-1111    |
    | mobile_phone | 444-123-3333    |
    | employer     | Dallas Genetics |
    | title        | Supervisor      |

  And dall.pub@example.com has the following information:
    | phone        | 333-123-1111    |
    | mobile_phone | 333-123-3333    |
    | employer     | Dallas Genetics |
    | title        | Receptionist    |

  And dall.md@example.com has the following information:
    | phone        | 222-123-1111    |
    | mobile_phone | 222-123-3333    |
    | employer     | Dallas Genetics |
    | title        | Doctor          |

  And delayed jobs are processed

Scenario: Public-only user can not navigate to Find People
  Given I am logged in as "dall.pub@example.com"
  When I go to the ext dashboard page
  And I wait for the "Loading PHIN" mask to go away
  And I sleep 2
  Then I should see the following toolbar items in "top_toolbar":
    | My Account |
  And I should not see the following toolbar items in "top_toolbar":
    | Find People |

Scenario: Search for a users from subordinate jurisdictions
  Given I am logged in as "tex.admin@example.com"
  When I go to the ext dashboard page
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  # search for user by partial first name
  When I search for a user with the following:
   | Name         | Pott                   |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"
  And I should see "Potter Public"
  And I should see "Potter MD"

  # search for user by partial last name
  When I search for a user with the following:
    | Name         | Adm                    |
    | Email        |                        |
    | Phone        |                        |
    | Title        |                        |
    | Roles        |                        |
    |Jurisdictions |                        |
  Then I should see "Potter Admin"
  And I should see "Dallas Admin"
  And I should see "Texas Admin"

  #search for user by partial first and last name
  When I search for a user with the following:
    | Name         | Pott Adm               |
    | Email        |                        |
    | Phone        |                        |
    | Title        |                        |
    | Roles        |                        |
    |Jurisdictions |                        |
  Then I should see "Potter Admin"

  #search for user by display name
  When I search for a user with the following:
    | Name         | Potter Admin           |
    | Email        |                        |
    | Phone        |                        |
    | Title        |                        |
    | Roles        |                        |
    |Jurisdictions |                        |
  Then I should see "Potter Admin"

  #search for user by partial email address
  When I search for a user with the following:
   | Name         |                        |
   | Email        | pott.ad                |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"

  #search for user by partial phone number
  When I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        | 888                    |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"


  #search for user by partial job title
  When I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"
  And I should see "Dallas Admin"

  #search for user by role
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Admin                  |
   |Jurisdictions |                        |
  Then I should see "Texas Admin"
  And I should see "Potter Admin"
  And I should see "Dallas Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions | Dallas County          |
  Then I should see "Dallas Admin"
  And I should see "Dallas Public"
  And I should see "Dallas MD"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by partial first name and partial title
  And I search for a user with the following:
   | Name         | Pott                   |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Admin                  |
   |Jurisdictions | Dallas County          |
  Then I should see "Dallas Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by partial first name and a role
  And I search for a user with the following:
   | Name         | Pott                   |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Admin                  |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by partial title and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        |                        |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by partial title, a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        | Admin                  |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"
  And I should see "Admin in Potter County"
  And I should see "pott.admin@example.com"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for user by partial title, a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Supervis               |
   | Roles        | Public                 |
   |Jurisdictions | Potter County          |
  Then I should not see "Potter Admin"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for users by several roles within a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Public,Admin           |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"
  Then I should see "Potter Public"

  # first release list choices
  When I close the active tab
  And I navigate to "Find People"
  #search for users by a role and several jurisdictions
  And I search for a user with the following:
   | Name         |                             |
   | Email        |                             |
   | Phone        |                             |
   | Title        |                             |
   | Roles        | Admin                       |
   |Jurisdictions | Potter County,Dallas County |
  Then I should see "Potter Admin"
  Then I should see "Dallas Admin"

  Scenario: Do not display deleted users
  Given "dall.md@example.com" is deleted as a user by "tex.admin@example.com"
  And delayed jobs are processed

  When I am logged in as "tex.admin@example.com"
  And I go to the ext dashboard page
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  When I search for a user with the following:
   | Name         |                        |
   | Email        | dall.md@example.com    |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should not see "Dallas MD"

  When I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions | Dallas County          |
  Then I should not see "Dallas MD"

Scenario: Results pagination
  Given the following users exist:
    | Potter Public1 | pott.pub1@example.com | Public | Potter County |
    | Potter Public2 | pott.pub2@example.com | Public | Potter County |
    | Potter Public3 | pott.pub3@example.com | Public | Potter County |
    | Potter Public4 | pott.pub4@example.com | Public | Potter County |
    | Potter Public5 | pott.pub5@example.com | Public | Potter County |
  And delayed jobs are processed
  When I am logged in as "tex.admin@example.com"
  And I go to the ext dashboard page
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  When I search for a user with the following:
   | Name         |                        |
   | Email        | example.com            |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Dallas MD"
  And I should see "Displaying results 1 - 10 of 12"

Scenario: Results can be sorted by name, verify blank photo present and can follow to the display of a user's profile
  Given I am logged in as "tex.admin@example.com"
  And I go to the ext dashboard page
  And I navigate to "Find People"
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions | Dallas County          |
  And I should see the image "/images/missing_tiny.jpg"
  Then I should see "Dallas Admin" in grid row 1
  And I should see "Dallas MD" in grid row 2
  And I should see "Dallas Public" in grid row 3

  When I click x-grid3-hd-inner "Search Results"
  Then I should see "Dallas Admin" in grid row 3
  And I should see "Dallas MD" in grid row 2
  And I should see "Dallas Public" in grid row 1

  When I click x-grid3-cell "Dallas MD"
  Then the "Profile: Dallas MD" tab should be open

Scenario: Search for a non-existent user in a jurisdiction
  Given I am logged in as "pott.md@example.com"
  When I go to the ext dashboard page
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  When I search for a user with the following:
   | Name         | Harry                  |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions | Potter County          |
  Then I should see "No users match your search request"
