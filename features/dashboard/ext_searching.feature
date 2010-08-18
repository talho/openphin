Feature: Searching for users
  In order to quickly find people I want to communicate with
  As a logged in user
  I can search

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Jurisdiction | Texas                 |
      | Role         | Public                |
      | approval role| Health Officer        |
      | Role         | Immunization Director |
      | Role         | HAN Coordinator       |
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jane Smith      | jane.smith@example.com   | Health Officer | Tarrant County |
      | Sam Body      | sam@example.com   | Health Officer | Dallas County |
      | Amy Body      | amy@example.com   | HAN Coordinator | Dallas County |
    And the user "Amy Body" with the email "amy@example.com" has the role "Admin" in "Dallas County"
    And "sam@example.com" has the title "Chief Bottle Washer"
    And "sam@example.com" has the phone "888-555-1212"
    And Health Officer is a non public role
    And HAN Coordinator is a non public role
    When delayed jobs are processed

  Scenario: Searching for a user
    Given I am logged in as "amy@example.com"
    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "Smith"
    And I press "Search"
    Then I should be on the ext dashboard page
    And I see the following users in the search results
      | John Smith, Jane Smith |
    And I should see "john.smith@example.com"
    And I should see "Public in Dallas County"
    And I should see "jane.smith@example.com"
    And I should see "Health Officer in Tarrant Count"

  Scenario: Searching for a user by a partial email address
    Given I am logged in as "amy@example.com"
    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "example"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith, Jane Smith, Amy Body, Sam Body |

  Scenario: Searching for a user by email address
    Given I am logged in as "amy@example.com"
    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "john.smith@example.com"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith |
    And I do not see the following users in the search results
      | Jane Smith, Amy Body, Sam Body |

  Scenario: Searching for a user as a user with only a public role
    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    Then I should not see "Find People"
    When I force open the tab "Search" for "/search/show_advanced?name=Smith"
    Then I should be on the ext dashboard page
    And I should see "You are not authorized"

  Scenario: Searching for a user as a user
    Given I am logged in as "sam@example.com"
    And jane.smith@example.com has a public profile

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "smith"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith, Jane Smith |
    When I follow "John Smith"
    And I should see "This user's profile is not public"

    When press "back" within "#tab_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "smith"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith, Jane Smith |
    When I follow "Jane Smith"
    And I should not see "This user's profile is not public"

  Scenario: Searching for a user as an admin
    Given I am logged in as "amy@example.com"
    And jane.smith@example.com has a public profile

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "smith"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith, Jane Smith |
    When I follow "John Smith"
    And I should not see "This user's profile is not public"

    When I press "back" within "#tab_toolbar"
    Then the "Find People" tab should be open
    When I fill in "Search" with "smith"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith, Jane Smith |
    When I follow "Jane Smith"
    Then I should not see "This user's profile is not public"

  Scenario: Search for a user from a specific jurisdiction
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Last name" with "smith"
    And I select "Tarrant County" from "_jurisdiction_ids"
    And I press "Search"
    Then I see the following users in the search results
      | Jane Smith |

  Scenario: Search for a user from a specific role
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Last name" with "smith"
    And I select "Public" from "_role_ids"
    And I press "Search"
    Then I see the following users in the search results
      | John Smith |

  Scenario: Search for a user from a specific role and a specific jurisdiction
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    When I fill in "Last name" with "body"
    And I select "Health Officer" from "_role_ids"
    And I select "Dallas County" from "_jurisdiction_ids"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a non-existent user from a specific role and a specific jurisdiction
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Last name" with "body"
    And I select "Immunization Director" from "_role_ids"
    And I select "Dallas County" from "_jurisdiction_ids"
    And I press "Search"
    Then I should see "No Results Found"

  Scenario: Search for a user by first name
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "First name" with "sam"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by last name
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Last name" with "body"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by display name
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Display name" with "sam body"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by email address
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Email" with "sam@example.com"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by phone
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Phone" with "888-555-1212"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by job title
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    And I fill in "Job Title" with "Chief Bottle Washer"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |

  Scenario: Search for a user by first name and last name
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    When I fill in "First name" with "Amy"
    And I fill in "Last name" with "Body"
    And I press "Search"
    Then I see the following users in the search results
      | Amy Body |
    And I should not see "Sam Body"

  Scenario: Search for a user by partial job title using wildcard
    Given I am logged in as "amy@example.com"

    When I go to the ext dashboard page
    And I press "Find People" within "#top_toolbar"
    Then the "Find People" tab should be open
    When I click inlineLink "Advanced Search" within ".content"
    When I fill in "First name" with "sa*"
    And I press "Search"
    Then I see the following users in the search results
      | Sam Body |
    And I should not see "Amy Body"
