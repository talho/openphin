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

  And delayed jobs are processed


@people
Scenario: Public-only user can not navigate to Find People
  Given I am logged in as "dall.pub@example.com"
  And I wait for the "Loading PHIN" mask to go away
  Then I should see the following toolbar items in "top_toolbar":
    | Dallas Public |
  And I should not see the following toolbar items in "top_toolbar":
    | Find People |


@people
Scenario: Initiate search by using the RETURN key and verify Form ClearAll
  Given I am logged in as "pott.admin@example.com"
  And pott.admin@example.com has the following information:
   | title        | Supervisor      |
   | phone        | 888-123-1111    |
  And delayed jobs are processed
  And I navigate to "Find People"
  And I fill in "Name" with "Potter"
  And I send return to "[name='conditions[name]']"
  Then I should see "Potter Admin"
  When I press "Reset"
  Then I should not see "Po" within "[name='conditions[name]']"

  When I fill in "Email Address" with "pott.admin@example.com"
  And I send return to "[name='conditions[email]']"
  Then I should see "Potter Admin"
  When I press "Reset"
  Then I should not see "pott.admin@example.com" within "[name='conditions[email]']"

  When I fill in "Phone" with "888-123-1111"
  And I send return to "[name='conditions[phone]']"
  Then I should see "Potter Admin"
  When I press "Reset"
  Then I should not see "888-123-1111" within "[name='conditions[phone]']"

  When I fill in "Job Title" with "Supervisor"
  And I send return to "[name='conditions[title]']"
  Then I should see "Potter Admin" in grid row 1
  When I press "Reset"
  Then I should not see "Supervisor" within "[name='conditions[title]']"


@people
Scenario: Search for a non-existent user in a jurisdiction and that roles/jurisdictions can be selected/unselected
  Given I am logged in as "pott.md@example.com"
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  When I click rol-list-item "Public"
  Then I should see "Public" within ".find-people-roles-select .x-list-selected"

  When I click rol-list-item "Medical Director"
  Then I should see "Medical Director" within ".find-people-roles-select .x-list-selected"

  When I press "Clear All" within ".find-people-roles-select"
  Then I should not have ".x-list-selected" within ".find-people-roles-select"

  When I click jur-list-item "Potter County"
  Then I should see "Potter County" within ".find-people-jurisdictions-select .x-list-selected"

  When I click jur-list-item "Dallas County"
  Then I should see "Dallas County" within ".find-people-jurisdictions-select .x-list-selected"

  When I press "Clear All" within ".find-people-jurisdictions-select"
  Then I should not have ".x-list-selected" within ".find-people-jurisdictions-select"

  When I click rol-list-item "Public"
  And I click jur-list-item "Potter County"
  And I press "Reset"
  Then I should not have ".x-list-selected" within ".find-people-roles-select"
  And I should not have ".x-list-selected" within ".find-people-jurisdictions-select"

  When I search for a user with the following:
   | Name         | Harry                  |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions | Potter County          |
  Then I should see "No users match your search request"


@people
Scenario: Search for a users from subordinate jurisdictions
  Given pott.admin@example.com has the following information:
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
  And I am logged in as "tex.admin@example.com"

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
   | Roles        | Phin: Admin            |
   |Jurisdictions |                        |
  Then I should see "Texas Admin"
  And I should see "Potter Admin"
  And I should see "Dallas Admin"

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

  #search for user by partial first name and partial title
  And I search for a user with the following:
   | Name         | Pott                   |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"

  #search for user by a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Phin: Admin            |
   |Jurisdictions | Dallas County          |
  Then I should see "Dallas Admin"

  #search for user by partial first name and a role
  And I search for a user with the following:
   | Name         | Pott                   |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        | Phin: Admin            |
   |Jurisdictions |                        |
  Then I should see "Potter Admin"

  #search for user by partial title and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        |                        |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"

  #search for user by partial title, a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Super                  |
   | Roles        | Phin: Admin            |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"
  And I should see "Admin in Potter County"
  And I should see "pott.admin@example.com"

  #search for user by partial title, a role and a jurisdiction
  And I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        | Supervis               |
   | Roles        | Public                 |
   |Jurisdictions | Potter County          |
  Then I should see "Potter Admin"

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

  #search for users by a role and several jurisdictions
  And I search for a user with the following:
   | Name         |                             |
   | Email        |                             |
   | Phone        |                             |
   | Title        |                             |
   | Roles        | Phin: Admin                 |
   |Jurisdictions | Potter County,Dallas County |
  Then I should see "Potter Admin"
  Then I should see "Dallas Admin"


@people
Scenario: Do not display deleted users
  Given "dall.md@example.com" is deleted as a user by "tex.admin@example.com"
  And delayed jobs are processed

  When I am logged in as "tex.admin@example.com"
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
   | Name          |               |
   | Email         |               |
   | Phone         |               |
   | Title         |               |
   | Roles         |               |
   | Jurisdictions | Dallas County |
  Then I should not see "Dallas MD"


@people
Scenario: Results pagination
  Given the following users exist:
    | Potter Public1 | pott.pub1@example.com | Public | Potter County |
    | Potter Public2 | pott.pub2@example.com | Public | Potter County |
    | Potter Public3 | pott.pub3@example.com | Public | Potter County |
    | Potter Public4 | pott.pub4@example.com | Public | Potter County |
    | Potter Public5 | pott.pub5@example.com | Public | Potter County |
  And delayed jobs are processed

  When I am logged in as "tex.admin@example.com"
  And I navigate to "Find People"
  Then I should see "People Search"
  And the "Find People" tab should be open

  When I search for a user with the following:
   | Name          |             |
   | Email         | example.com |
   | Phone         |             |
   | Title         |             |
   | Roles         |             |
   | Jurisdictions |             |
  Then I should see "Dallas MD"
  And I should see "Displaying results 1 - 10 of 12"


@people
Scenario: Results can be sorted by name, verify blank photo present and can follow to the display of a user's profile
  Given I am logged in as "tex.admin@example.com"
  And I navigate to "Find People"
  And I search for a user with the following:
   | Name          |               |
   | Email         |               |
   | Phone         |               |
   | Title         |               |
   | Roles         |               |
   | Jurisdictions | Dallas County |
  And I should see the image "/assets/missing_tiny.jpg"
  Then I should see "Dallas Admin" in grid row 1
  And I should see "Dallas MD" in grid row 2
  And I should see "Dallas Public" in grid row 3

  When I click x-grid3-hd-inner "Search Results"
  And the "Search Results" grid header is sorted descending 
  Then I should see "Dallas Admin" in grid row 3
  And I should see "Dallas MD" in grid row 2
  And I should see "Dallas Public" in grid row 1

  When I click x-grid3-cell "Dallas MD"
  Then the "Profile: Dallas MD" tab should be open

@people
Scenario: User cannot search for users in a different app
  Given the following users exist:
    | Notin Myapp | notinmyapp@example.com | Public | Dallas County | vms |
  And "notinmyapp@example.com" is not public in "Texas"
  And delayed jobs are processed

  When I am logged in as "tex.admin@example.com"
  And I navigate to "Find People"

  When I search for a user with the following:
   | Name         |                        |
   | Email        |                        |
   | Phone        |                        |
   | Title        |                        |
   | Roles        |                        |
   |Jurisdictions |                        |
  Then I should not see "Notin Myapp"

  When I search for a user with the following:
   | Name          | Notin         |
   | Email         |               |
   | Phone         |               |
   | Title         |               |
   | Roles         |               |
   | Jurisdictions |               |
  Then I should not see "Notin Myapp"
