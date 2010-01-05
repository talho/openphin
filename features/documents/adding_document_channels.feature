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
    When I go to the the document viewing panel

  Scenario: Creating a new channel
    And I follow "New Share"
    And I fill in "Share Name" with "Discovery"
    And I press "Create Share"

    Then I should be redirected to the document viewing panel
    And I should see "Discovery"
    And I should see "(John Smith)"

  Scenario: Adding a document to a share
    Given I created the share "Channel 4"
    And "brandon.keepers@example.com" has been added to the share "Channel 4"
    And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Channel 4"
    And I press "Share"
    Then "brandon.keepers@example.com" should receive the email:
      | subject       | A document has been added to the share "Channel 4" |
      | body contains | To view this document |
    And I should be redirected to the folder inbox page

    When I go to the document viewing panel
    And I follow "Channel 4"
    Then I should see "sample.wav"

#  Scenario: User copying a document out of share
#    Given I have been added to the share "Vacation Photos"
#    And a document "keith.jpg" is in the share "Vacation Photos"
#    And I have a folder named "Hilarious"
#    When I go to the document viewing panel
#    And I follow "Vacation Photos"
#    And I check "keith.jpg"
#    And I follow "Copy"
#    And I select "Hilarious" from "Folder"
#    And I press "Copy"
#    Then I should be redirected to the document viewing panel
#
#    When I follow "Hilarious"
#    Then I should see "keith.jpg"

  Scenario: Inviting users to a share
    Given I created the share "Avian Flus"

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the document viewing panel
    Then I should not see "Avian Flus"

    Given I am logged in as "john.smith@example.com"
    When I go to the document viewing panel
    And I check "Avian Flus"
    And I follow "Invite"

    When I fill out the share invitation form with:
      | People | Brandon Keepers |
    And I press "Invite"
    Then I should be redirected to the document viewing panel
    And "brandon.keepers@example.com" should receive the email:
      | subject       | John Smith added you to a share |
      | body contains | To view this channel |

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the document viewing panel
    Then I should see "Avian Flus"

  Scenario: Unsubscribing from a share
    Given I have been added as owner to the share "Kitty Pictures"
    And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"
    And I am logged in as "brandon.keepers@example.com"
    When I go to the document viewing panel
    And I check "Kitty Pictures"
    And I follow "Unsubscribe"

    Then I should be redirected to the document viewing panel
    And I should not see "Kitty Pictures"

  Scenario: Unsubscribing from a share while I am the only owner
    Given I have been added as owner to the share "Kitty Pictures"
    And "brandon.keepers@example.com" has been added to the share "Kitty Pictures"
    When I go to the document viewing panel
    And I check "Kitty Pictures"
    And I follow "Unsubscribe"

    Then I should be redirected to the document viewing panel
    And I should see "Kitty Pictures"

  Scenario: Removing document from share
    Given I created the share "Channel 4"
    And a document "keith.jpg" is in the share "Channel 4"

    When I go to the document viewing panel
    And I follow "Channel 4"
    And I should see "Contents of Channel 4"
    And I should see "keith.jpg"
    And I follow "Delete"
    Then I should not see "keith.jpg"

  Scenario: Deleting a share
    Given I created the share "Avian Flus"
    When I go to the document viewing panel
    And I check "Avian Flus"
    And I follow "Delete Share"
    Then I should be on the show destroy Share page for "Avian Flus"
    And I should see "Avian Flus"
    And I should see "John Smith"
    Then I press "Delete"
    And I should be redirected to the document viewing panel
    And I should not see "Avian Flus"
