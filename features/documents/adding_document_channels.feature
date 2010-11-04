Feature: Creating document channels
  In order to push documents to groups of people while keeping documents current
  As a user
  I should be able to create a document channel that other users can subscribe to

  Background:
    Given the following entities exists:
      | Jurisdiction  | Dallas County  |
      | Jurisdiction  | Texas          |
      | Approval Role | Health Officer |
      | Approval Role | Epidemiologist |
    And the following users exist:
      | John Smith      | john.smith@example.com      | Health Officer  | Dallas County |
      | Brandon Keepers | brandon.keepers@example.com | Epidemiologist  | Texas         |
    And I am logged in as "john.smith@example.com"
    And I go to the dashboard page
    When delayed jobs are processed

   Scenario: Creating a new channel
     When I follow "Documents"
     And I wait for the "#new_share_folder" element to load
     And I select "#new_share_folder" from the documents toolbar
     When I fill in "Share Name" with "Discovery"
     And I press "Create Share"
     Then I should see "Discovery"
     And I should see "(John Smith)"

   Scenario: Adding a document to a share
     Given I created the share "Channel 4"
     And "brandon.keepers@example.com" has been added to the share "Channel 4"
     And I have the document "sample.wav" in my inbox

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish

     When I follow "Inbox"
     Then I wait for the "#documents_progress_panel" element to finish

     When I check "sample.wav"
     And I select "#add_to_share" from the documents toolbar
     Then I wait for the "div#share div#edit" element to load

     When I check "Channel 4"
     And I press "Share"
     Then I wait for the "#documents_progress_panel" element to finish

     When I follow "Channel 4"
     And I wait for the "#documents_progress_panel" element to finish
     Then I should see "sample.wav"
     And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Channel 4" |
      | body contains | To view this document |

   Scenario:Inviting users to a share
     Given I created the share "Avian Flu"
     And I go to the dashboard page
     Given I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish
     Then I should not see "Avian Flu"
     And I go to the dashboard page

     Given I am logged in as "john.smith@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     And I check "Avian Flu"
     And I select "#invite" from the documents toolbar
     And I wait for the "div#invitation div#audience" element to load
     When I fill out the share invitation form with:
      | People | Brandon Keepers |
     And I press "Invite"
     Then I wait for the "#documents_progress_panel" element to finish
     And "brandon.keepers@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this share |
     And I go to the dashboard page
     
     Given I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish
     Then I should see "Avian Flu"

   Scenario: Unsubscribing from a share
     Given I have been added as owner to the share "Kitty Pictures"
     And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"
     And I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish

     When I check "Kitty Pictures"
     And I will confirm on next step
     And I select "#unsubscribe" from the documents toolbar
     Then I wait for the "#document_progress_panel" element to finish
     And I should not see "Kitty Pictures"

   Scenario: Unsubscribing from a share while I am the only owner
     Given I have been added as owner to the share "Kitty Pictures"
     And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish

     When I check "Kitty Pictures"
     And I will confirm on next step
     And I select "#unsubscribe" from the documents toolbar
     Then I wait for the "#document_progress_panel" element to finish
     And I should see "Kitty Pictures"

   Scenario: Removing documents from share
     Given I created the share "Channel 4"
     And a document "keith.jpg" is in the share "Channel 4"

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish

     When I follow "Channel 4"
     Then I wait for the "#document_progress_panel" element to finish
     And I should see "Contents of Channel 4"
     And I should see "keith.jpg"
     And I check "keith.jpg"
     And I will confirm on next step
     And I select "#delete_file" from the documents toolbar
     Then I wait for the "#document_progress_panel" element to finish
     And I should not see "keith.jpg"

   Scenario: Deleting a share
     Given I created the share "Avian Flu"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#document_progress_panel" element to finish
     And I check "Avian Flu"
     And I select "#delete" from the documents toolbar
     Then I wait for the "div#deletion div#share" element to load
     And I should see "Avian Flu" within "div#deletion div#share"
     And I should see "John Smith" within "div#deletion div#share"
     And I will confirm on next step
     Then I press "Delete"
     And I wait for the "#document_progress_panel" element to finish
     And I should not see "Avian Flu"

   Scenario: User attempts to share a document located in his shared folder that is not his
     Given I have the document "sample.wav" in my inbox
     Given I created the share "Discover"
     Given "brandon.keepers@example.com" has been added to the share "Discover"

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Inbox"
     Then I wait for the "#documents_progress_panel" element to finish
     When I check "sample.wav"
     And I select "#add_to_share" from the documents toolbar
     Then I wait for the "div#share div#edit" element to load
     When I check "Discover"
     And I press "Share"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     And I wait for the "#documents_progress_panel" element to finish
     Then I should see "sample.wav"
     And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Discover" |
      | body contains | To view this document |

     Given I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     Then I wait for the "#document_progress_panel" element to finish
     And I should see "Contents of Discover"
     And I should see "sample.wav"
     And I check "sample.wav"
     And I select "#add_to_share" from the documents toolbar
     Then I should see "Sorry, you don't have access to this file"

  Scenario: User attempts to Move/Edit a document located in his shared folder that is not his
     Given I have the document "sample.wav" in my inbox
     Given I created the share "Discover"
     Given "brandon.keepers@example.com" has been added to the share "Discover"

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Inbox"
     Then I wait for the "#documents_progress_panel" element to finish
     When I check "sample.wav"
     And I select "#add_to_share" from the documents toolbar
     Then I wait for the "div#share div#edit" element to load
     When I check "Discover"
     And I press "Share"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     And I wait for the "#documents_progress_panel" element to finish
     Then I should see "sample.wav"
     And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Discover" |
      | body contains | To view this document |

     Given I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     Then I wait for the "#document_progress_panel" element to finish
     And I should see "Contents of Discover"
     And I should see "sample.wav"
     And I check "sample.wav"
     And I select "#move_edit" from the documents toolbar
     Then I should see "Sorry, you don't have access to this file"

    Scenario: User attempts to delete a document located in his shared folder that is not his
     Given I have the document "sample.wav" in my inbox
     Given I created the share "Discover"
     Given "brandon.keepers@example.com" has been added to the share "Discover"

     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Inbox"
     Then I wait for the "#documents_progress_panel" element to finish
     When I check "sample.wav"
     And I select "#add_to_share" from the documents toolbar
     Then I wait for the "div#share div#edit" element to load
     When I check "Discover"
     And I press "Share"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     And I wait for the "#documents_progress_panel" element to finish
     Then I should see "sample.wav"
     And "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Discover" |
      | body contains | To view this document |

     Given I am logged in as "brandon.keepers@example.com"
     When I go to the dashboard page
     And I follow "Documents"
     Then I wait for the "#documents_progress_panel" element to finish
     When I follow "Discover"
     Then I wait for the "#document_progress_panel" element to finish
     And I should see "Contents of Discover"
     And I should see "sample.wav"
     And I check "sample.wav"
     And I will confirm on next step
     And I select "#delete_file" from the documents toolbar
     Then I should see "Sorry, you don't have access to this file"