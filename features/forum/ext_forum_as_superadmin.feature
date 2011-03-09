
Feature: Creating a forum (room)

  In order to allow for discussion of various and possibly arbitrary topics
  As a super-administrator
  I should be able to create a forum that can hold user-created topics

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
      | Jurisdiction | Potter County |
      | Role         | Health Officer |
    And Texas is the parent jurisdiction of:
      | Dallas County |
      | Potter County |
    And a role named Public
    And there is an system administrator role
    And  Health Officer is a non public role
    And the following users exist:
      | Jane Smith | jane.smith@example.com | Public | Dallas County |
      | Jeff Brown | jeff.brown@example.com | Public | Dallas County |
      | Joe Black  | joe.black@example.com  | Public | Potter County |
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Joe Black" with the email "joe.black@example.com" has the role "Health Officer" in "Potter County"
    And there is an system administrator role
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "Superadmin" in "Texas"
    And I am on the dashboard page


  # issue: currently a forum without an audience does not show to anyone outside of superadmins.
  # I think that a forum without an audience should show to all users, no matter role
  Scenario: Create and edit a forum
    Given I am logged in as "joe.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I should see "Add Forum"
    And I press "Add Forum"
    Then the "New Forum" window should be open
    When I fill in "Forum Name" with "Funding methodology"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    Then I should see "Funding methodology"

    When I click edit_forum on the "Funding methodology" grid row
    And I fill in "Forum Name" with "Seeking funding"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then I should see "Seeking funding"
    And I should not see "Funding methodology"

    When I click edit_forum on the "Seeking funding" grid row
    And I check "Hidden"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then I should see "Seeking funding"

    When I navigate to "Joe Smith > Sign Out"
    When I am logged in as "jane.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should not see "Seeking funding"


  Scenario: Restrict the particular forum audience with jurisdiction & role
    Given I am logged in as "joe.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I should see "Add Forum"
    And I press "Add Forum"
    And I fill in "Forum Name" with "Funding methodology"
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    Then I should see "Funding methodology"

    When I navigate to "Joe Smith > Sign Out"
    When I am logged in as "jane.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should see "Funding methodology"

    When I navigate to "Jane Smith > Sign Out"
    When I am logged in as "joe.black@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should not see "Funding methodology"


  Scenario: Edit the jurisdiction of an existing forum audience
    Given I am logged in as "joe.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I should see "Add Forum"
    And I press "Add Forum"
    And I fill in "Forum Name" with "Funding methodology"
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Health Officer | Role         |
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    Then I should see "Funding methodology"

    When I navigate to "Joe Smith > Sign Out"
    When I am logged in as "joe.black@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should not see "Funding methodology"

    When I navigate to "Joe Black > Sign Out"
    When I am logged in as "joe.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    When I click edit_forum on the "Funding methodology" grid row
    And I select the following in the audience panel:
      | name           | type         |
      | Potter County  | Jurisdiction |
    And I press "Save"

    When I navigate to "Joe Smith > Sign Out"
    And I am logged in as "joe.black@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should see "Funding methodology"


  Scenario: Restrict the particular forum audience with jurisdiction only
    Given I am logged in as "joe.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I should see "Add Forum"
    And I press "Add Forum"
    And I fill in "Forum Name" with "Funding methodology"
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I should see "Funding methodology"

    When I navigate to "Joe Smith > Sign Out"
    When I am logged in as "jane.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should see "Funding methodology"

    When I navigate to "Jane Smith > Sign Out"
    When I am logged in as "joe.black@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    Then I should not see "Funding methodology"


  Scenario: Create a topic to a particular forum
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Forum to verify sticky topics"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Forum to verify sticky topics" grid row
    And I press "New Topic"
    And I fill in "Topic Title" with "Sticky topic that was created earlier"
    And I fill in "Topic Content" with "Desc for my topic"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    Then I should see "Sticky topic that was created earlier"

    When 1 minute passes
    And I press "New Topic"
    And I fill in "Topic Title" with "Second created but not sticky topic"
    And I fill in "Topic Content" with "Desc for my topic"
    And I press "Save"

    When Time is back to normal
    And I wait for the "Saving..." mask to go away
    Then I should see "Second created but not sticky topic" in grid row 1
    And I should see "Sticky topic that was created earlier" in grid row 2

    When I click edit_topic on the "Sticky topic that was created earlier" grid row
    And I check "Pinned"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Sticky topic that was created earlier" in grid row 1
    And I should see "Second created but not sticky topic" in grid row 2
    And the "Sticky topic that was created earlier" grid row should have the topic_pinned icon


  Scenario: Move an existing forum topic to an alternate forum as a super-admin
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Saving Money"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    Then I should see "Measuring Fulfillment"

    When I click move_topic on the "Measuring Fulfillment" grid row
    And I select "Saving Money" from ext combo "Forum to move topic to"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    And I select the "Saving Money" grid row
    And I wait for the "Loading..." mask to go away
    Then I should see "Measuring Fulfillment"

    And I select the "Grant Capturing" grid row
    And I wait for the "Loading..." mask to go away
    Then I should not see "Measuring Fulfillment"


  Scenario: Hide a topic as an super-admin and verify that an user can not see it
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |

    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click edit_topic on the "Measuring Fulfillment" grid row
    And I check "Hidden"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then I should see "Measuring Fulfillment"

    When I navigate to "Joe Smith > Sign Out"
    When I am logged in as "jane.smith@example.com"
    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    Then I should not see "Measuring Fulfillment"


  Scenario: Close a topic as an super-admin
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |

    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click edit_topic on the "Measuring Fulfillment" grid row
    And I check "Closed"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Measuring Fulfillment"
    And the "Measuring Fulfillment" grid row should have the topic_closed icon


  Scenario: Delete a topic as an super-admin
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |

    And I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I will confirm on next step
    And I click delete_topic on the "Measuring Fulfillment" grid row
    And I press "Yes"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Measuring Fulfillment" within ".x-grid3"


  Scenario: Editing a forum concurrently to another admin editing the same forum
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Forum to verify concurrency"
    When I navigate to the ext dashboard page
    And I navigate to "Forums"

    And I click edit_forum on the "Forum to verify concurrency" grid row
    And I select the following in the audience panel:
      | name           | type         |
      | Dallas County  | Jurisdiction |

    Given session name is "admin session"
    And I am logged in as "joe.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Forums"

    And I click edit_forum on the "Forum to verify concurrency" grid row 
    And I select the following in the audience panel:
      | name           | type         |
      | Potter County  | Jurisdiction |
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I navigate to "Joe Smith > Sign Out"

    Given session name is "default"
    When I press "Save"
    Then I should see "This forum was recently changed by another user. Please try again."

  Scenario: Editing forum topics concurrently to another admin editing the same forum topic
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | joe.smith@example.com |
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click edit_topic on the "Measuring Fulfillment" grid row
    And I fill in "Topic Title" with "Measuring Reward"

    Given session name is "admin session"
    And I am logged in as "joe.smith@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click edit_topic on the "Measuring Fulfillment" grid row
    And I fill in "Topic Title" with "Measuring Time"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Measuring Time" within ".x-grid3-cell"
    And I navigate to "Joe Smith > Sign Out"

    Given session name is "default"
    When I override alert
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    Then I should see "Another user recently updated the same topic.  Please try again." within the alert box
    When I press "Cancel"
    Then I should not see "Measuring Reward"
    When I click edit_topic on the "Measuring Fulfillment" grid row
    And I fill in "Topic Title" with "Measuring Reward"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Measuring Reward"