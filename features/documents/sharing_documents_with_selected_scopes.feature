Feature: Sharing documents with selected scopes

  In order to send documents to groups of users
  As a user
  I can send documents

  Background:
    Given the following entities exists:
      | Jurisdiction  | Dallas County                               |
      | Jurisdiction  | Tarrant County                              |
      | Jurisdiction  | Wise County                                 |
      | Jurisdiction  | Potter County                               |
      | Jurisdiction  | Texas                                       |
      | Jurisdiction  | Federal                                     |
      | Approval Role | Health Alert and Communications Coordinator |
      | Approval Role | Immunization Director                       |
      | Approval Role | Epidemiologist                              |
      | Approval Role | WMD Coordinator                             |
    And Federal is the parent jurisdiction of:
      | Texas |
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |
    And the following users exist:
      | John Smith      | john.smith@example.com      | Health Alert and Communications Coordinator  | Dallas County  |
      | Brian Simms     | brian.simms@example.com     | Epidemiologist                               | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com     | Public                                       | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com     | Health Alert and Communications Coordinator  | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com    | Epidemiologist                               | Wise County    |
      | Jason Phipps    | jason.phipps@example.com    | WMD Coordinator                              | Potter County  |
      | Dan Morrison    | dan.morrison@example.com    | Health Alert and Communications Coordinator  | Ottawa County  |
      | Brian Ryckbost  | brian.ryckbost@example.com  | Health Alert and Communications Coordinator  | Tarrant County |
    And "john.smith@example.com" is not public in "Texas"
    And "brian.simms@example.com" is not public in "Texas"
    And "ed.mcguyver@example.com" is not public in "Texas"
    And "ethan.waldo@example.com" is not public in "Texas"
    And "keith.gaddis@example.com" is not public in "Texas"
    And "jason.phipps@example.com" is not public in "Texas"
    And "dan.morrison@example.com" is not public in "Texas"
    And "brian.ryckbost@example.com" is not public in "Texas"
    When delayed jobs are processed

    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#new_share_folder" from the documents toolbar
    And I fill in "Share Name" with "Rockstars"
    And I press "Create Share"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#add_to_share" from the documents toolbar
    And I wait for the "div#share div#edit" element to load
    And I check "Rockstars"
    And I press "Share"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "Rockstars"
    And I select "#invite" from the documents toolbar
    Then I wait for the "div#invitation div#audience" element to load

  Scenario: Sending a document directly to a user
    When I fill out the document sharing form with:
      | People | Keith Gaddis |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this share, go to:        |
    And I go to the dashboard page

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sharing a document with multiple users
    When I fill out the document sharing form with:
      | People | Keith Gaddis, Dan Morrison, Ed McGuyver |

    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And the following users should receive the email:
      | People        | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | John Smith invited you to a share                     |
      | body contains | To view this share, go to:                            |
    And "ed.mcguyver@example.com" should not receive an email
    And I go to the dashboard page

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"
    And I go to the dashboard page

    Given I am logged in as "dan.morrison@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions shares it with all users within those Jurisdictions
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |

    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com |
      | subject       | John Smith invited you to a share               |
      | body contains | To view this share, go to:                      |
    And "ed.mcguyver@example.com" should not receive an email
    And I go to the dashboard page
    
    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"
    And I go to the dashboard page

    Given I am logged in as "brian.simms@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions/Roles scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County, Tarrant County |
      | Roles         | Health Alert and Communications Coordinator                |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com, brian.ryckbost@example.com |
      | subject       | John Smith invited you to a share                                           |
      | body contains | To view this share, go to:                                                  |
    And "brian.simms@example.com" should not receive an email
    And I go to the dashboard page
    
    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"
    And I go to the dashboard page

    Given I am logged in as "ethan.waldo@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"
    And I go to the dashboard page

    Given I am logged in as "brian.simms@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "Rockstars"

  Scenario: Sharing a document with a specified Jurisdictions/Organization scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish

    And the following users should receive the email:
      | People        | john.smith@example.com            |
      | subject       | John Smith invited you to a share |
      | body contains | To view this share, go to:        |
    And "ed.mcguyver@example.com" should not receive an email
    And I go to the dashboard page

    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"
    And I go to the dashboard page

    Given I am logged in as "ed.mcguyver@example.com"
    Then I should not see "Documents"

  Scenario: Forwarding documents to another group of recipients as owners
    #we're switching from the concept of switching ownership to setting up user permissions and such
    Then "Audience authorship" should be implemented
    #When I fill out the document sharing form with:
    #  | People | Keith Gaddis |
    #And I check "Make these people owners"
    #And I press "Invite"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I go to the dashboard page
    #
    #Given I am logged in as "keith.gaddis@example.com"
    #When I go to the dashboard page
    #And I follow "Documents"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I should see "Rockstars"
    #And I check "Rockstars"
    #And I select "#invite" from the documents toolbar
    #Then I wait for the "div#invitation div#audience" element to load
    #And I fill out the document sharing form with:
    #  | People | Brian Ryckbost |
    #And I press "Invite"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I go to the dashboard page
    #And "brian.ryckbost@example.com" should receive the email:
    #  | subject       | John Smith invited you to a share |
    #  | body contains | To view this share, go to:        |
    #
    #Given I am logged in as "brian.ryckbost@example.com"
    #When I go to the dashboard page
    #And I follow "Documents"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I follow "Rockstars"
    #Then I wait for the "#document_progress_panel" element to finish
    #And I should see "sample.wav"

  Scenario: Forwarding documents to another group of recipients who are not owners
    When I fill out the document sharing form with:
      | People | Keith Gaddis |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And I go to the dashboard page

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "Keith Gaddis" is not an owner of "Rockstars"

  Scenario: Inviting a user who is already subscribed as a non-owner and promoting them to owner
    When I fill out the document sharing form with:
      | People | Keith Gaddis |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this share, go to:        |
    And I go to the dashboard page

    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "Rockstars"
    And I select "#invite" from the documents toolbar
    Then I wait for the "div#invitation div#audience" element to load
    And I fill out the document sharing form with:
      | People | Keith Gaddis |
    And I press "Invite"
    Then I wait for the "#document_progress_panel" element to finish
    And "keith.gaddis@example.com" should receive the email:
      | subject        | John Smith invited you to a share |
      | body contains  | To view this share, go to:        |
    And I go to the dashboard page

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "John Smith" is an owner of "Rockstars"