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
    And I navigate to the new invitation page

  Scenario: Create and Send an invite
    When I fill in "Invitation Name:" with "DSHS"
    And I fill in "Email Subject:" with "Please Join DSHS"
    And I fill in the htmleditor "Email Body:" with "Please click the link below to join DSHS."
    And I select "DSHS" from ext combo "Default Organization:"
    And I press "Next"
    And I press "Add User"
    And I fill in "invitee_name" with "Jane Smith"
    And I fill in "invitee_email" with "jane.smith@example.com"
    And I sleep 1
    And I press "Update"
    And I sleep 1
    When I press "Send Invitation"
    Then I should see "Invitation was successfully sent"
    Then "jane.smith@example.com" is an invitee of "DSHS"
    And "joe.smith@example.com" is not an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email                  | message                                   |
      | jane.smith@example.com | Please click the link below to join DSHS. |

    When I signup for an account with the following info:
      | Email                                   | jane.smith@example.com |
      | Password                                | Apples1                |
      | Password Confirmation                   | Apples1                |
      | First Name                              | Jane                   |
      | Last Name                               | Smith                  |
      | Preferred name                          | Jane Smith             |
      | Home Jurisdiction                       | Texas                  |
      | Preferred language                      | English                |
      | Are you with any of these organizations | DSHS                   |
      | Are you a public health professional?   | <checked>              |
    And "jane.smith@example.com" clicks the confirmation link in the email
    And I am logged in as "joe.smith@example.com"
    And I navigate to the invitations page
    And I select the "DSHS" grid cell

    Then I should see "Invitation: DSHS"
    And I should see "Jane Smith"
    And I should see "jane.smith@example.com"
    And I should see "Yes"

  Scenario: Create and Send an invite to an existing user
    And I fill in "Invitation Name:" with "DSHS"
    And I fill in "Email Subject:" with "Please Join DSHS"
    And I fill in the htmleditor "Email Body:" with "Please click the link below to join DSHS."
    And I select "DSHS" from ext combo "Default Organization:"
    And I press "Next"
    And I press "Add User"
    And I fill in "invitee_name" with "Joe Smith"
    And I fill in "invitee_email" with "joe.smith@example.com"
    And I sleep 1
    When I press "Update"
    And I sleep 1
    And I press "Send Invitation"
    Then I should see "Invitation was successfully sent"
    And "joe.smith@example.com" is an invitee of "DSHS"
    When delayed jobs are processed
    Then the following Emails should be broadcasted:
      | email                 | message                                               |
      | joe.smith@example.com | You have been made a member of the organization DSHS. |

  Scenario: Create and Send an invite via a CSV file with invitees
    And I fill in "Invitation Name:" with "DSHS"
    And I fill in "Email Subject:" with "Please Join DSHS"
    And I fill in the htmleditor "Email Body:" with "Please click the link below to join DSHS."
    And I select "DSHS" from ext combo "Default Organization:"
    And I press "Next"
    When I attach the file "spec/fixtures/invitees.csv" with button "Import Users"
    When I press "Send Invitation"
    Then I should see "Invitation was successfully sent"
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
      
    When I navigate to the invitations page
    Then I should see "DSHS" in grid row 1  
    And I should see "TORCH" in grid row 2
    
    When I select the "DSHS" grid cell
    Then I should see "Invitation: DSHS"
    And I should see "Subject: Please Join DSHS" with html stripped
    And I should see "Please click the link below to join DSHS" in an htmleditor
    And I should see "Default Organization: DSHS" with html stripped
    And I should see "Jane" in grid row 1 column 1 within "#invitationGrid"
    And I should see "jane.smith@example.com" in grid row 1 column 2 within "#invitationGrid"
    And I should see "Bob" in grid row 2 column 1 within "#invitationGrid"
    And I should see "bob.smith@example.com" in grid row 2 column 2 within "#invitationGrid"
  
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

    When I navigate to the invitations page
    Then I should see "DSHS" in grid row 1

    When I select the "DSHS" grid cell
    And I select the "Email" grid header

    Then I should see "Invitation: DSHS"
    And I should see "Registrations complete: 60% (3)" with html stripped
    And I should see "Registrations incomplete: 40% (2)" with html stripped
    And I should see "Bill Smith" in grid row 1 column 1 within "#invitationGrid"
    And I should see "bill.smith@example.com" in grid row 1 column 2 within "#invitationGrid"
    And I should see "Not Registered" in grid row 1 column 3 within "#invitationGrid"
    And I should see "Bob Smith" in grid row 2 column 1 within "#invitationGrid"
    And I should see "bob.smith@example.com" in grid row 2 column 2 within "#invitationGrid"
    And I should see "Not Registered" in grid row 2 column 3 within "#invitationGrid"
    And I should see "Jane Smith" in grid row 3 column 1 within "#invitationGrid"
    And I should see "jane.smith@example.com" in grid row 3 column 2 within "#invitationGrid"
    And I should see "Registered" in grid row 3 column 3 within "#invitationGrid"
    And I should see "Jim Smith" in grid row 4 column 1 within "#invitationGrid"
    And I should see "jim.smith@example.com" in grid row 4 column 2 within "#invitationGrid"
    And I should see "Registered" in grid row 4 column 3 within "#invitationGrid"
    And I should see "John Smith" in grid row 5 column 1 within "#invitationGrid"
    And I should see "john.smith@example.com" in grid row 5 column 2 within "#invitationGrid"
    And I should see "Registered" in grid row 5 column 3 within "#invitationGrid"

  Scenario: Viewing invitation completion status by registrations
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

    When I navigate to the invitations page
    Then I should see "DSHS" in grid row 1

    When I select the "DSHS" grid cell
    And I select the "Completion Status" grid header

    Then I should see "Registrations complete: 40% (2)" with html stripped
    And I should see "Registrations incomplete: 60% (3)" with html stripped
    And I should see "John Smith" in grid row 1 column 1 within "#invitationGrid"
    And I should see "john.smith@example.com" in grid row 1 column 2 within "#invitationGrid"
    And I should see "Not Email Confirmed" in grid row 1 column 3 within "#invitationGrid"
    And I should see "Jane Smith" in grid row 2 column 1 within "#invitationGrid"
    And I should see "jane.smith@example.com" in grid row 2 column 2 within "#invitationGrid"
    And I should see "Registered" in grid row 2 column 3 within "#invitationGrid"
    And I should see "Jim Smith" in grid row 3 column 1 within "#invitationGrid"
    And I should see "jim.smith@example.com" in grid row 3 column 2 within "#invitationGrid"
    And I should see "Registered" in grid row 3 column 3 within "#invitationGrid"
    And I should see "Bill Smith" in grid row 4 column 1 within "#invitationGrid"
    And I should see "bill.smith@example.com" in grid row 4 column 2 within "#invitationGrid"
    And I should see "Not Registered" in grid row 4 column 3 within "#invitationGrid"
    And I should see "Bob Smith" in grid row 5 column 1 within "#invitationGrid"
    And I should see "bob.smith@example.com" in grid row 5 column 2 within "#invitationGrid"
    And I should see "Not Registered" in grid row 5 column 3 within "#invitationGrid"

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

    When I navigate to the invitations page
    Then I should see "DSHS" in grid row 1

    When I select the "DSHS" grid cell
    And I select the "Organization Members" grid header

    Then I should see "Default Organization: DSHS" with html stripped
    And I should see "Jane Smith" in grid row 1 column 1 within "#invitationGrid"
    And I should see "jane.smith@example.com" in grid row 1 column 2 within "#invitationGrid"
    And I should see "Yes" in grid row 1 column 4 within "#invitationGrid"
    And I should see "Joe Smith" in grid row 2 column 1 within "#invitationGrid"
    And I should see "joe.smith@example.com" in grid row 2 column 2 within "#invitationGrid"
    And I should see "Yes" in grid row 2 column 4 within "#invitationGrid"
    And I should see "Bob Smith" in grid row 3 column 1 within "#invitationGrid"
    And I should see "bob.smith@example.com" in grid row 3 column 2 within "#invitationGrid"
    And I should see "No" in grid row 3 column 3 within "#invitationGrid"

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

    When I navigate to the invitations page
    Then I should see "DSHS" in grid row 1

    When I select the "DSHS" grid cell
    And I select the "Pending Role Requests" grid header

    Then I should see "John Smith"
    And I should see "Bob Smith" in grid row 1 column 1 within "#invitationGrid"
    And I should see "bob.smith@example.com" in grid row 1 column 2 within "#invitationGrid"
    And I should see "Click here to see" in grid row 1 column 6 within "#invitationGrid"
    And I should see "John Smith" in grid row 2 column 1 within "#invitationGrid"
    And I should see "john.smith@example.com" in grid row 2 column 2 within "#invitationGrid"
    And I should see "Click here to see" in grid row 2 column 6 within "#invitationGrid"
    And I should see "Jane Smith" in grid row 3 column 1 within "#invitationGrid"
    And I should see "jane.smith@example.com" in grid row 3 column 2 within "#invitationGrid"
    And I should not see "Click here to see" in grid row 3 column 6 within "#invitationGrid"
    And I should see "Joe Smith" in grid row 4 column 1 within "#invitationGrid"
    And I should see "joe.smith@example.com" in grid row 4 column 2 within "#invitationGrid"
    And I should not see "Click here to see" in grid row 4 column 6 within "#invitationGrid"

  Scenario: Viewing invitation completion status by profile update
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
    And I show dropdown menus
    And I follow "View Invitations"
    Then I should see "DSHS"

    When I follow "View Reports"
    And I select "By Profile Update" from "Report type"

    Then I should see "Invitation report for DSHS by Profile Update"
    And I should see "Registrations complete: 40% (2)"
    And I should see "Registrations incomplete: 60% (3)"
    
    And I should see "Jane Smith" within "#invitee1"
    And I should see "jane.smith@example.com" within "#invitee1"
    And I should see "No" within "tr#invitee1 td.status"
    And I should see "Jim Smith" within "#invitee2"
    And I should see "jim.smith@example.com" within "#invitee2"
    And I should see "No" within "tr#invitee1 td.status"
