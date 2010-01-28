
  Feature: Creating a forum (room)

  In order to allow for discussion of various and possibly arbitrary topics
  As a super-administrator
  I should be able to create a forum that can hold user-created topics

  Background:
    Given an organization named Red Cross
    And the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And a role named Public
    And the following users exist:
      | Jane Smith | jane.smith@example.com | Public | Dallas County |
      | Jeff Brown | jeff.brown@example.com | Public | Dallas County |
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And there is an system administrator role
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "Superadmin" in "Texas"

  Scenario: Create and edit a forum
    When I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "New forum"
    And I fill in "Name" with "Funding methodology"
    And I press "Create"

    Then I should be redirected to the Forums page
    And I should see "Forum was successfully created"
    And I should see "Funding methodology"

    When I follow "Edit"
    And I fill in "Name" with "Seeking funding"
    And I press "Update"
    Then I should see "Seeking funding"

    And I follow "Edit"
    When I check "Hide"
    And I press "Update"
    And I should see "Forum was successfully updated"
    Then I should see "Seeking funding"

    When I am logged in as "jane.smith@example.com"
    And I go to the Forums page
    Then I should not see "Seeking funding"


  Scenario: Restrict the particular forum audience
    When I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    And I follow "New forum"
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
    Then I should not see "Funding methodology"


  Scenario: Create a topic to a particular forum
    Given I am logged in as "jane.smith@example.com"
    And I have the forum named "Forum to verify sticky topics"
    And I go to the Forums page
    And I follow "Topics"
    And I follow "New topic"
    And I fill in "Name" with "First created but not sticky topic"
    And I press "Create"

    Then I should be redirected to the Topics page for Forum "Forum to verify sticky topics"
    And I should see "Topic was successfully created"
    And I should see "First created but not sticky topic"

    When I follow "New topic"
    And I fill in "Name" with "Sticky topic that was created later"
    And I press "Create"

    Then I should be redirected to the Topics page for Forum "Forum to verify sticky topics"
    And I should see "Topic was successfully created"
    And I should see "Sticky topic that was created later" within "#topic_name_1"
    And I should see "First created but not sticky topic" within "#topic_name_0"

  Scenario: Delete a topic from a forum
    And I am logged in as "joe.smith@example.com"
    And I go to the Forums page
    
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
    
  Scenario: Edit an existing comment to a topic as a super-admin or the original poster
    Given I am logged in as "joe.smith@example.com"
    And I have the comment "Walmart claims 100% fulfillment" to topic "Measuring Fulfillment" to forum "Grant Capturing"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should see "Measuring Fulfillment"

    When I follow "Edit"
    And I fill in "Comment" with "Look at who is counting"
    And I press "Update"
    Then I should see "Topic was successfully updated"
    When I follow "Measuring Fulfillment"
    And I should not see "Walmart claims 100% fulfillment"
    And I should see "Look at who is counting"

