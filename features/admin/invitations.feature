Feature: Invitation System
  In order to get people to register in the system
  As an administrator
  I should be able to use the invitation system to invite people by email to sign up
  And I should to be see reports on people's sign up progress

  Background: 
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Organization | DSHS          |
      | Organization | TORCH         |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com      |
    And I am logged in as "joe.smith@example.com"
    And I am on the dashboard page
    
  Scenario: Create and Send an invite
    When I follow "Admin"
    And I follow "Invite Users"
    And I should see "Invite New People"
    And I fill in "Name" with "DSHS"
    And I fill in "Subject" with "Please Join DSHS"
    And I fill in "Body" with "Please click the link below to join DSHS."
    And I select "DSHS" from "Default Organization"
    And I fill in "Invitee Name" with "Jane Smith"
    And I fill in "Invitee Email" with "jane.smith@example.com"
    When I press "Submit"
    Then I should see "Invitation was successfully sent."
    And "jane.smith@example.com" is an invitee of "DSHS"
    And "joe.smith@example.com" is not an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email                  | message                                   |
      | jane.smith@example.com | Please click the link below to join DSHS. |

  Scenario: Create and Send an invite to an existing user
    When I follow "Admin"
    And I follow "Invite Users"
    And I should see "Invite New People"
    And I fill in "Name" with "DSHS"
    And I fill in "Subject" with "Please Join DSHS"
    And I fill in "Body" with "Please click the link below to join DSHS."
    And I select "DSHS" from "Default Organization"
    And I fill in "Invitee Name" with "Joe Smith"
    And I fill in "Invitee Email" with "joe.smith@example.com"
    When I press "Submit"
    Then I should see "Invitation was successfully sent."
    And "joe.smith@example.com" is an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email                 | message                                               |
      | joe.smith@example.com | You have been made a member of the organization DSHS. |

  Scenario: Create and Send an invite via a CSV file with invitees
    When I follow "Admin"
    And I follow "Invite Users"
    And I should see "Invite New People"
    And I fill in "Name" with "DSHS"
    And I fill in "Subject" with "Please Join DSHS"
    And I fill in "Body" with "Please click the link below to join DSHS."
    And I select "DSHS" from "Default Organization"
    When I attach the file at "spec/fixtures/invitees.csv" to "CSV File"
    When I press "Submit"
    Then I should see "Invitation was successfully sent."
    And "bob@example.com" is an invitee of "DSHS"
    And "john@example.com" is an invitee of "DSHS"
    And "joe.smith@example.com" is not an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email            | message                                   |
      | bob@example.com  | Please click the link below to join DSHS. |
      | john@example.com | Please click the link below to join DSHS. |
      
  Scenario: View the list of existing invitations to organizations
    Given an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And an Invitation "TORCH" exists with:
      | Subject      | Please Join TORCH                         |
      | Body         | Please click the link below to join TORCH |
      | Organization | TORCH                                     |
    
    And invitation "DSHS" has the following invitees:
      | Jane | jane.smith@example.com |
      | Bob  | bob.smith@example.com  |
    And invitation "TORCH" has the following invitees:
      | Joe | joe.smith@example.com |
      
    When I follow "Admin"
    And I follow "View Invitations"
    Then I should see "Existing Invitations"
    And I should see "DSHS"
    And I should see "TORCH"
    
    When I follow "DSHS"
    Then I should see "DSHS Invitation"
    And I should see "Please Join DSHS" within "#subject"
    And I should see "Please click the link below to join DSHS" within "#body"
    And I should see "DSHS" within "#default_organization"
    And I should see "Jane <jane.smith@example.com>" within "#invitees"
    And I should see "Bob <bob.smith@example.com>" within "#invitees"
  
  Scenario: Viewing invitation completion status by email
    Given an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And invitation "DSHS" has the following invitees:
      | Jane Smith | jane.smith@example.com |
      | Bob Smith  | bob.smith@example.com  |
      | John Smith | john.smith@example.com |
      | Bill Smith | bill.smith@example.com |
      | Jim Smith  | jim.smith@example.com  |
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Public" in "Texas"
    And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Potter"
    And the user "Jim Smith" with the email "jim.smith@example.com" has the role "Health Officer" in "Andrews"

    When I follow "Admin"
    And I follow "View Invitations"
    Then I should see "DSHS"

    When I follow "View Reports"
    And I select "By Email" from "Report Type"
    And I press "Submit"

    Then I should see "Invitation report for DSHS by email address"
    And I should see "Registrations complete: 60% (3)"
    And I should see "Registrations incomplete: 40% (2)"
    And I should see "Bill Smith" within "#invitee1"
    And I should see "bill.smith@example.com" within "#invitee1"
    And I should explictly see "Not Registered" within "tr#invitee1 td.status"
    And I should see "Bob Smith" within "#invitee2"
    And I should see "bob.smith@example.com" within "#invitee2"
    And I should explictly see "Not Registered" within "#invitee2 td.status"
    And I should see "Jane Smith" within "#invitee3"
    And I should see "jane.smith@example.com" within "#invitee3"
    And I should explictly see "Registered" within "#invitee3 td.status"
    And I should see "Jim Smith" within "#invitee4"
    And I should see "jim.smith@example.com" within "#invitee4"
    And I should explictly see "Registered" within "#invitee4 td.status"
    And I should see "John Smith" within "#invitee5"
    And I should see "john.smith@example.com" within "#invitee5"
    And I should explictly see "Registered" within "#invitee5 td.status"

  Scenario: Viewing invitation completion status by email
    Given an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And invitation "DSHS" has the following invitees:
      | Jane Smith | jane.smith@example.com |
      | Bob Smith  | bob.smith@example.com  |
      | John Smith | john.smith@example.com |
      | Bill Smith | bill.smith@example.com |
      | Jim Smith  | jim.smith@example.com  |
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Public" in "Texas"
    And the user "John Smith" with the email "john.smith@example.com" has the role "Epidemiologist" in "Potter"
    And the user "Jim Smith" with the email "jim.smith@example.com" has the role "Health Officer" in "Andrews"
    And "john.smith@example.com" is an unconfirmed user
    
    When I follow "Admin"
    And I follow "View Invitations"
    Then I should see "DSHS"

    When I follow "View Reports"
    And I select "By Registrations" from "Report Type"
    And I press "Submit"

    Then I should see "Invitation report for DSHS by registrations"
    And I should see "Registrations complete: 60% (3)"
    And I should see "Registrations incomplete: 40% (2)"
    And I should see "Bill Smith" within "#invitee1"
    And I should see "bill.smith@example.com" within "#invitee1"
    And I should explictly see "Not Registered" within "tr#invitee1 td.status"
    And I should see "Bob Smith" within "#invitee2"
    And I should see "bob.smith@example.com" within "#invitee2"
    And I should explictly see "Not Registered" within "#invitee2 td.status"
    And I should see "John Smith" within "#invitee3"
    And I should see "john.smith@example.com" within "#invitee3"
    And I should explictly see "Not Email Confirmed" within "#invitee3 td.status"
    And I should see "Jane Smith" within "#invitee4"
    And I should see "jane.smith@example.com" within "#invitee4"
    And I should explictly see "Registered" within "#invitee4 td.status"
    And I should see "Jim Smith" within "#invitee5"
    And I should see "jim.smith@example.com" within "#invitee5"
    And I should explictly see "Registered" within "#invitee5 td.status"

  Scenario: Viewing invitation completion status by organization membership
    Given an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Public" in "Texas"
    And invitation "DSHS" has the following invitees:
      | Jane Smith | jane.smith@example.com |
      | Bob Smith  | bob.smith@example.com  |
      | Joe Smith  | joe.smith@example.com  |

    When I follow "Admin"
    And I follow "View Invitations"
    Then I should see "DSHS"

    When I follow "View Reports"
    And I select "By Organization" from "Report Type"
    And I press "Submit"

    Then I should see "Invitation report for DSHS by organization"
    And I should see "Organization: DSHS"
    And I should see "Bob Smith" within "#invitee1"
    And I should see "bob.smith@example.com" within "#invitee1"
    And I should explictly see "No" within "#invitee1 td.status"
    And I should see "Jane Smith" within "#invitee2"
    And I should see "jane.smith@example.com" within "#invitee2"
    And I should explictly see "Yes" within "#invitee2 td.status"
    And I should see "Joe Smith" within "#invitee3"
    And I should see "joe.smith@example.com" within "#invitee3"
    And I should explictly see "Yes" within "#invitee3 td.status"

  Scenario: Viewing invitation completion status by pending role requests
    Given the following entities exist:
      | Jurisdiction | Potter County   |
      | Role         | Health Official |
      | Role         | Health Officer  |
    And Health Official is a non public role
    And Health Officer is a non public role
    And an Invitation "DSHS" exists with:
      | Subject      | Please Join DSHS                         |
      | Body         | Please click the link below to join DSHS |
      | Organization | DSHS                                     |
    And the user "Bob Smith" with the email "bob.smith@example.com" has the role "Public" in "Texas"
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Official" in "Texas"
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "Public" in "Potter County"
    And the user "John Smith" with the email "john.smith@example.com" has the role "Public" in "Texas"
    And "bob.smith@example.com" has requested to be a "Health Official" for "Texas"
    And "joe.smith@example.com" has requested to be a "Health Officer" for "Potter County"
    And invitation "DSHS" has the following invitees:
      | Bob Smith  | bob.smith@example.com  |
      | Jane Smith | jane.smith@example.com |
      | Joe Smith  | joe.smith@example.com  |
      | John Smith | john.smith@example.com |
    And "john.smith@example.com" is an unconfirmed user
    And "john.smith@example.com" has requested to be a "Health Official" for "Texas"

    When I follow "Admin"
    And I follow "View Invitations"
    Then I should see "DSHS"

    When I follow "View Reports"
    And I select "By Pending Requests" from "Report Type"
    And I press "Submit"

    Then I should see "Invitation report for DSHS by pending role requests"
    And I should see "Bob Smith" within "#invitee1"
    And I should see "bob.smith@example.com" within "#invitee1"
    And I should see "Health Official" within "#invitee1"
    And I should see "Texas" within "#invitee1"
    And I should see "Joe Smith" within "#invitee2"
    And I should see "joe.smith@example.com" within "#invitee2"
    And I should see "Health Officer" within "#invitee2"
    And I should see "Potter County" within "#invitee2"
    And I should not see "Jane Smith"
    And I should not see "John Smith"