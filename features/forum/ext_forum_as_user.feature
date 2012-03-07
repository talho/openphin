Feature: Creating a topic to a forum as a user

In order to allow for discussion of various and possibly arbitrary topics
As a user with access
I should be able to create topics to forums and place comments to these topics

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
      | Role         | Health Officer |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And a role named Public
    And there is an system administrator role
    And  Health Officer is a non public role
    And the following users exist:
      | Jane Smith  | jane.smith@example.com  | Public | Dallas County |
      | Harry Simon | harry.simon@example.com | Public | Dallas County |
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Harry Simon" with the email "harry.simon@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "SuperAdmin" in "Texas"

  Scenario: View all of the proper controls: No edit forum, close or move topic, but edit topic yes
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com, harry.simon@example.com  |
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row

    Then the "Grant Capturing" grid row should not have the edit_forum icon
    And the "Measuring Fulfillment" grid row should not have the move_topic icon
    And the "Measuring Fulfillment" grid row should not have the delete_topic icon
    And the "Measuring Fulfillment" grid row should have the edit_topic icon

    When I navigate to "Jane Smith > Sign Out"
    And I am logged in as "harry.simon@example.com"
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row

    Then the "Grant Capturing" grid row should not have the edit_forum icon
    And the "Measuring Fulfillment" grid row should not have the move_topic icon
    And the "Measuring Fulfillment" grid row should not have the delete_topic icon
    And the "Measuring Fulfillment" grid row should not have the edit_topic icon


  Scenario: Create a topic and edit the topic as the poster
    Given I am logged in as "jane.smith@example.com"
    And I have the forum named "Funding methodology"
    And the forum "Funding methodology" has the following audience:
      | Users | jane.smith@example.com  |
    When I navigate to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Funding methodology" grid row
    And I press "New Topic"
    And I fill in "Topic Title" with "Locating Grants in todays economy"
    And I fill in "Topic Content" with "Desc for my topic"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Locating Grants in todays economy"
    And I should see "Jane Smith"

    When I click edit_topic on the "Locating Grants in todays economy" grid row
    And I fill in "Topic Title" with "todays economic impact on grants"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "todays economic impact on grants"

    
  Scenario: Editing forum topics concurrently to another admin editing the same forum topic
    # Given I am logged in as "jane.smith@example.com"
    # And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    # And the forum "Grant Capturing" has the following audience:
      # | Users | jane.smith@example.com |
    # When I navigate to the ext dashboard page
    # And I navigate to "Forums"
    # And I select the "Grant Capturing" grid row
    # And I click edit_topic on the "Measuring Fulfillment" grid row
    # And I fill in "Topic Title" with "Measuring Reward"
#     
    # Given session name is "admin session"
    # And I am logged in as "joe.smith@example.com"
    # When I navigate to the ext dashboard page
    # And I navigate to "Forums"
    # And I select the "Grant Capturing" grid row
    # And I click edit_topic on the "Measuring Fulfillment" grid row
    # And I fill in "Topic Title" with "Measuring Time"
    # And I press "Save"
    # And I wait for the "Saving..." mask to go away
    # And I wait for the "Loading..." mask to go away
    # Then I should see "Measuring Time" within ".x-grid3"
# 
    # Given session name is "default"
    # When I override alert
    # And I press "Save"
    # And I should see "Saving..."
    # And I wait for the "Saving..." mask to go away
    # Then I should see "Another user recently updated the same topic.  Please try again." within the alert box
    # And I fill in "Topic Title" with "Measuring Reward"
    # And I press "Save"
    # And I wait for the "Saving..." mask to go away
    # And I wait for the "Loading..." mask to go away
    # Then I should see "Measuring Reward"
