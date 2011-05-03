Feature: Viewing user profiles
  In order to foster a sense of community
  As a user
  I should be able to view public profiles of other users
  
  Background:
    Given the following entities exists:
    | Jurisdiction | Texas          |
    | Jurisdiction | Dallas County  |
    | Jurisdiction | Potter County  |
    And Texas is the parent jurisdiction of:
      | Dallas County | Potter County |
     And the following users exist:
  	  | John Smith      | john.smith@example.com   | Public | Dallas County |
  	  | Sam Body        | sam.body@example.com     | Public | Dallas County |
  	  | Big Admin       | big.admin@example.com    | Public | Dallas County |
    And I am logged in as "john.smith@example.com"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Health Officer" in "Dallas County"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Dallas County"
  	And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Potter County"
  	And the user "Sam Body" with the email "sam.body@example.com" has the role "Health Officer" in "Dallas County"
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "Epidemiologist" in "Dallas County"
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "Epidemiologist" in "Potter County"
    And Health Officer is a non public role
    And Epidemiologist is a non public role
    And  "john.smith@example.com" has the phone "888-123-1212"
    And  "john.smith@example.com" has the fax "888-456-1212"
    And  "john.smith@example.com" has the mobile phone "888-432-1212"
    And  "john.smith@example.com" has the home phone "888-555-1212"
    And delayed jobs are processed
    And the sphinx daemon is running
    
  Scenario: Viewing a public profile
    Given sam.body@example.com has a public profile
    When I view the profile page for "sam.body@example.com"
    Then I can see the profile
    And I should see the following roles:
      | Health Officer | Dallas County |
    
  Scenario: Viewing a private profile
    Given sam.body@example.com has a private profile
    When I view the profile page for "sam.body@example.com"
    Then I should see "This user's profile is not public"
  
  Scenario: Viewing my private profile
    Given john.smith@example.com has a private profile
    When I view the profile page for "john.smith@example.com"
    Then I can see the profile
    And I can see the following roles:
      | Public         | Dallas County |
      | Health Officer | Dallas County |
      | Epidemiologist | Dallas County |
      | Epidemiologist | Potter County |
    And I should see "888-123-1212" within ".office_phone"
    And I should see "888-456-1212" within ".office_fax"
    And I should see "888-432-1212" within ".mobile_phone"
    And I should see "888-555-1212" within ".home_phone"
   
      
  Scenario: Viewing my own profile as an admin
    Given big.admin@example.com has a private profile
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "Admin" in "Texas"
    And I am logged in as "big.admin@example.com"
    When I view the profile page for "big.admin@example.com"
    Then I can see the profile
    And I can see the following roles:
      | Phin: Admin   | Texas         |
      | Epidemiologist | Dallas County |
      | Epidemiologist | Potter County |

  Scenario: Viewing my own profile as an superadmin
    Given big.admin@example.com has a private profile
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "SuperAdmin" in "Texas"
    And I am logged in as "big.admin@example.com"
    When I view the profile page for "big.admin@example.com"
    Then I can see the profile
    And I can see the following roles:
      | Phin: SuperAdmin | Texas         |
      | Epidemiologist    | Dallas County |
      | Epidemiologist    | Potter County |
  
  Scenario: Viewing anothers profile as an admin
    Given john.smith@example.com has a private profile
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "Admin" in "Dallas County"
    And I am logged in as "big.admin@example.com"
    When I view the profile page for "john.smith@example.com"
    And I can see the following roles:
      | Public         | Dallas County |
      | Health Officer | Dallas County |
      | Epidemiologist | Dallas County |
      | Epidemiologist | Potter County |
    Then I should see "888-123-1212" within ".office_phone"
    And I should see "888-456-1212" within ".office_fax"
    And I should see "888-432-1212" within ".mobile_phone"
    And I should see "888-555-1212" within ".home_phone"
    
  Scenario: Viewing anothers profile as an admin of the same jurisdiction
    Given john.smith@example.com has a private profile
    And an organization exist with the following info:
      | name               | DSHS                                |
      | distribution_email | disco@example.com                   |
      | postal_code        | 787202                              |
      | street             | 123 Elm Street                      |
      | phone              | 888-555-1212                        |
      | description        | Department of State Health Services |
      | locality           | Austin                              |
      | state              | TX                                  |
  	And the user "Big Admin" with the email "big.admin@example.com" has the role "Admin" in "Texas"

    When I am logged in as "big.admin@example.com"
    And I view the profile page for "john.smith@example.com"
    Then I should see "888-123-1212" within ".office_phone"
    And I should see "888-456-1212" within ".office_fax"
    And I should see "888-432-1212" within ".mobile_phone"
    And I should see "888-555-1212" within ".home_phone"


  Scenario: Viewing anothers profile as an fellow member to an organization
    Given john.smith@example.com has a private profile
    And an organization exist with the following info:
      | name               | DSHS                                |
      | description        | Department of State Health Services |
      | distribution_email | disco@example.com                   |
      | street             | 123 Elm Street                      |
      | phone              | 888-555-1212                        |
      | locality           | Austin                              |
      | state              | TX                                  |
      | postal_code        | 78720                               |
    And "john.smith@example.com" is a member of the organization "DSHS"
    And "sam.body@example.com" is a member of the organization "DSHS"
    And I am logged in as "sam.body@example.com"
    When I view the profile page for "john.smith@example.com"
    Then I should see "888-123-1212" within ".office_phone"
    And I should see "888-456-1212" within ".office_fax"
    And I should not see "888-432-1212"
    And I should not see "888-555-1212"


