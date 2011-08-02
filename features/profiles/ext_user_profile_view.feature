Feature: Viewing user profiles
In order to provide contact and identification information and foster a sense of community,
As a PHIN user or admin
I should be able to see user profiles

Background:
  Given the following entities exist:
    | role         | Admin            |
    | role         | Medical Director |
    | role         | Public           |
    | jurisdiction | Texas            |
    | jurisdiction | Dallas County    |
    | jurisdiction | Potter County    |
    | organization | TALHO            |
    | organization | USDA             |

  And Medical Director is a non public role

  And Texas is the parent jurisdiction of:
    | Dallas County, Potter County |

  And the following users exist:
    | Texas Admin     | tex.admin@example.com    | Admin            | Texas          |
    | Dallas Admin    | dall.admin@example.com   | Admin            | Dallas County  |
    | Dallas MD       | dall.md@example.com      | Medical Director | Dallas County  |
    | Dallas Public   | dall.pub@example.com     | Public           | Dallas County  |
    | Potter Admin    | pott.admin@example.com   | Admin            | Potter County  |
    | Potter MD       | pott.md@example.com      | Medical Director | Potter County  |
    | Potter Public   | pott.pub@example.com     | Public           | Potter County  |

  And pott.pub@example.com has the following information:
    | phone        | 888-123-1111                                                              |
    | mobile_phone | 888-123-3333                                                              |
    | employer     | Applied Genetics                                                          |
    | description  | Supervisor for the Genetic Laundromat (night shift)                       |
    | bio          | They call me Mr. Clean Genes                                              |
    | credentials  | I've been washing genes since I was old enough to sequence my shoelaces   |
    | experience   | Born in Japan and Educated in Germany but those countries are low on DNA. |

Scenario: User can view their own profile
  Given pott.pub@example.com has a public profile
  And I am logged in as "pott.pub@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Potter Public > View My Profile"
  Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |

  When I press "Edit This Account"
  Then the "Edit Account: Potter Public" tab should be open


Scenario: Public user viewing a public profile
  Given pott.pub@example.com has a public profile
  And I am logged in as "dall.pub@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |

  And I should not see "Edit This Account"


Scenario: Public user viewing a private profile
  Given pott.pub@example.com has a private profile
  And I am logged in as "dall.pub@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
     | Potter Public                         |
     | pott.pub@example.com                  |
     | Public in Potter County               |
   And I should not see:
     | 888-123-1111                          |
     | 888-123-3333                          |
     | Applied Genetics                      |
     | Supervisor for the Genetic Laundromat |
     | They call me Mr. Clean Genes          |
     | I've been washing genes               |
     | Born in Japan and Educated in Germany |

  And I should not see "Edit This Account"


Scenario: User with a non-public, non-admin role viewing a public profile
  Given pott.pub@example.com has a public profile
  And I am logged in as "dall.md@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |
 
  And I should not see "Edit This Account"


Scenario: User with a non-public, non-admin role viewing a private profile
  Given pott.pub@example.com has a private profile
  And I am logged in as "dall.md@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
     | Potter Public                         |
     | pott.pub@example.com                  |
     | Public in Potter County               |
   And I should not see:
     | 888-123-1111                          |
     | 888-123-3333                          |
     | Applied Genetics                      |
     | Supervisor for the Genetic Laundromat |
     | They call me Mr. Clean Genes          |
     | I've been washing genes               |
     | Born in Japan and Educated in Germany |

  And I should not see "Edit This Account"


Scenario: Admin viewing a subordinate public profile
  Given pott.pub@example.com has a public profile
  And I am logged in as "pott.admin@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |

  When I press "Edit This Account"
  Then the "Edit Account: Potter Public" tab should be open


Scenario: Admin viewing a non-subordinate public profile
  Given pott.pub@example.com has a public profile
  And I am logged in as "dall.admin@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |

  And I should not see "Edit This Account"


Scenario: Admin viewing a subordinate private profile
  Given pott.pub@example.com has a private profile
  And I am logged in as "pott.admin@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
   | Potter Public                         |
   | pott.pub@example.com                  |
   | Public in Potter County               |
   | 888-123-1111                          |
   | 888-123-3333                          |
   | Applied Genetics                      |
   | Supervisor for the Genetic Laundromat |
   | They call me Mr. Clean Genes          |
   | I've been washing genes               |
   | Born in Japan and Educated in Germany |

  When I press "Edit This Account"
  Then the "Edit Account: Potter Public" tab should be open


Scenario: Admin viewing a non-subordinate private profile
  # NO edit button
  Given pott.pub@example.com has a private profile
  And I am logged in as "dall.admin@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
   Then I should see:
     | Potter Public                         |
     | pott.pub@example.com                  |
     | Public in Potter County               |
   And I should not see:
     | 888-123-1111                          |
     | 888-123-3333                          |
     | Applied Genetics                      |
     | Supervisor for the Genetic Laundromat |
     | They call me Mr. Clean Genes          |
     | I've been washing genes               |
     | Born in Japan and Educated in Germany |

  And I should not see "Edit This Account"


Scenario: Fields should not be visible if they do not have data
  Given pott.pub@example.com has a public profile
  And I am logged in as "dall.md@example.com"
  And I navigate to the ext dashboard page
  And I should see "About TXPhin"

  And I view the ext profile page for "pott.pub@example.com"
    Then I should see:
      | Potter Public                         |
      | pott.pub@example.com                  |
      | Public in Potter County               |
      | 888-123-1111                          |
      | 888-123-3333                          |
      | Applied Genetics                      |
      | Supervisor for the Genetic Laundromat |
      | They call me Mr. Clean Genes          |
      | I've been washing genes               |
      | Born in Japan and Educated in Germany |
   And I should not see:
      | Home Phone |
      | Fax        |
      | Occupation |
   And pott.pub@example.com has the following information:
      | title      | Nerf Herder  |
      | home_phone | 888-123-4444 |
      | fax        | 888-123-2222 |
   And I close the active tab
  
   And I view the ext profile page for "pott.pub@example.com"
     Then I should see:
      | Potter Public                         |
      | pott.pub@example.com                  |
      | Public in Potter County               |
      | 888-123-1111                          |
      | 888-123-2222                          |
      | 888-123-3333                          |
      | 888-123-4444                          |
      | Applied Genetics                      |
      | Nerf Herder                           |
      | Supervisor for the Genetic Laundromat |
      | They call me Mr. Clean Genes          |
      | I've been washing genes               |
      | Born in Japan and Educated in Germany |