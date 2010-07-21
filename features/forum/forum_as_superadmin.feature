
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


  Scenario: Create and edit a forum
    Given I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "Add forum"
    And I fill in "Name" with "Funding methodology"
    And I press "Create"

    Then I should be redirected to the Forums page
    And I should see "Forum was successfully created"
    And I should see "Funding methodology"

    When I follow "Edit"
    And I fill in "Name" with "Seeking funding"
    And I press "Update"
    Then I should be redirected to the Forums page
    And I should see "Seeking funding"

    When I follow "Edit"
    And I check "Hide"
    And I press "Update"
    And I should see "Forum was successfully updated"
    Then I should be redirected to the Forums page
    And I should see "Seeking funding"

    When I am logged in as "jane.smith@example.com"
    And I go to the Forums page
    Then I should not see "Seeking funding"


  Scenario: Restrict the particular forum audience with jurisdiction & role
    Given I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "Add forum"
    And I fill in "Name" with "Funding methodology"
    And I fill out the audience form with:
      | Jurisdictions | Dallas County  |
      | Roles         | Health Officer |
    And I press "Create"

    Then I should be redirected to the Forums page
    And I should see "Forum was successfully created"
    And I should see "Funding methodology"

    When I am logged in as "jane.smith@example.com"
    And I go to the Forums page
    Then I should see "Funding methodology"

    When I am logged in as "jeff.brown@example.com"
    And I go to the Forums page
    Then I should see "You are not authorized to view this page"


  Scenario: Edit the jurisdiction of an existing forum audience
    Given I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "Add forum"
    And I fill in "Name" with "Funding methodology"
    And I fill out the audience form with:
      | Jurisdictions | Dallas County  |
      | Roles         | Health Officer |
    And I press "Create"

    Then I should be redirected to the Forums page
    And I should see "Forum was successfully created"
    And I should see "Funding methodology"

    When I am logged in as "jane.smith@example.com"
    And I go to the Forums page
    Then I should see "Funding methodology"

    When I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "Edit"
    And I check "Potter County"
    And I press "Update"
    And I am logged in as "joe.black@example.com"
    And I go to the Forums page
    Then I should see "Funding methodology"
    

  Scenario: Restrict the particular forum audience with jurisdiction only
    Given I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "Add forum"
    And I fill in "Name" with "Funding methodology"
    And I fill out the audience form with:
      | Jurisdictions | Dallas County  |
    And I press "Create"

    Then I should be redirected to the Forums page
    And I should see "Forum was successfully created"
    And I should see "Funding methodology"

    When I am logged in as "jane.smith@example.com"
    And I go to the Forums page
    Then I should see "Funding methodology"

    When I am logged in as "jeff.brown@example.com"
    And I go to the Forums page
    Then I should not see "Funding methodology"


  Scenario: Create a topic to a particular forum
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Forum to verify sticky topics"
    And I go to the Forums page
    And I follow "Forum to verify sticky topics"
    And I fill in "Name" with "Sticky topic that was created earlier"
    And I press "Add Topic"

    Then I should see "Topic was successfully created"
    And I should see "Sticky topic that was creat..."

    When 1 minute passes
    And I fill in "Name" with "Second created but not sticky topic"
    And I press "Add Topic"
    Then I should be redirected to the Topics page for Forum "Forum to verify sticky topics"
    And I should see "Topic was successfully created"

    
    And I should see "Second created but not stic..." within "#topic_name_1"
    And I should see "Sticky topic that was creat..." within "#topic_name_2"
    
    When I follow "edit_topic_2"
    And I check "topic_sticky"
    And I press "Update"
    Then I should see "Sticky topic that was creat..." within "#topic_name_1"
    And I should see "Second created but not stic..." within "#topic_name_2"

  Scenario: Move an existing forum topic to an alternate forum as a super-admin
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Saving Money"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should see "Measuring Fulfillment"
    
    When I follow "Edit"
    And I select "Saving Money" from "Forum to be moved to"
    And I press "Update"
    Then I should see "Topic was successfully updated"
    
    When I go to the Forums page
    And I follow "Saving Money"
    Then I should see "Measuring Fulfillment"
    
    When I follow "Forums"
    And I follow "Grant Capturing"
    Then I should not see "Measuring Fulfillment"
    

  Scenario: Edit as a super_admin an existing comment to a topic posted by someone else
    Given I am logged in as "jane.smith@example.com"
    And I have the comment "Walmart claims 100% fulfillment" to topic "Measuring Fulfillment" to forum "Grant Capturing"
    
    When I am logged in as "joe.smith@example.com"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should see "Measuring Fulfillment"

    When I follow "Edit"
    And I check "comment_ids_"
    And I fill in "Comment" with "Look at who is counting"
    And I press "Update Comment"
    Then I should see "Comments were successfully updated"
    And I should be redirected to the "Measuring Fulfillment" topic page for Forum "Grant Capturing"
    And I should not see "Walmart claims 100% fulfillment"
    And I should see "Look at who is counting"


  Scenario: Delete as a super_admin an existing comment to a topic posted by someone else
    Given I am logged in as "jane.smith@example.com"
    And I have the comment "Walmart claims 100% fulfillment" to topic "Measuring Fulfillment" to forum "Grant Capturing"

    When I am logged in as "joe.smith@example.com"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should see "Measuring Fulfillment"

    When I follow "Edit"
    And I check "delete_comment_ids_"
    And I press "Update Comment"
    Then I should see "Comments were successfully updated"
    And I should be redirected to the "Measuring Fulfillment" topic page for Forum "Grant Capturing"
    And I should not see "Walmart claims 100% fulfillment"

  Scenario: Hide a topic as an super-admin and verify that an user can not see it
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |

    When I go to the Topics page for Forum "Grant Capturing"
    And I follow "edit_topic_1"
    And I check "Hide"
    And I press "Update"
    Then I should see "Measuring Fulfillment"

    When I am logged in as "jane.smith@example.com"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should not see "Measuring Fulfillment"

  Scenario: Editing a forum concurrently to another admin editing the same forum
    Given I am logged in as "joe.smith@example.com"
    And I have the forum named "Forum to verify concurrency"
    When I load the edit Forum page for "Forum to verify concurrency"
    And I fill out the audience form with:
      | Jurisdictions | Dallas County  |

    Given session name is "admin session"
    And I am logged in as "joe.smith@example.com"
    When I load the edit Forum page for "Forum to verify concurrency"
    And I fill out the audience form with:
      | Jurisdictions | Potter County |
    And I press "Update"

    Given session name is "default"
    When I press "Update"
    Then I should see "This forum was recently changed by another user. Please try again." within ".error"