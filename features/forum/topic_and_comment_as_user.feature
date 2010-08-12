
Feature: Creating a topic to a forum as a user

In order to allow for discussion of various and possibly arbitrary topics
As a user with access
I should be able to create topics to forums and place comments to these topics

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas         |
      | Jurisdiction | Dallas County |
    And Texas is the parent jurisdiction of:
      | Dallas County |
    And a role named Public
    And the following users exist:
      | Jane Smith  | jane.smith@example.com  | Public | Dallas County |
      | Harry Simon | harry.simon@example.com | Public | Dallas County |
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Harry Simon" with the email "harry.simon@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "Superadmin" in "Texas"
    And the user "Jim Smith" with the email "jim.smith@example.com" has the role "Superadmin" in "Texas"


  Scenario: Create a topic and edit the topic as the poster
    Given I am logged in as "jane.smith@example.com"
    And I have the forum named "Funding methodology"
    And the forum "Funding methodology" has the following audience:
      | Users | jane.smith@example.com  |
    When I go to the Forums page
    And I follow "Funding methodology"
    And I fill in "Name" with "Locating Grants in todays economy"
    And I press "Add Topic"

    Then I should be redirected to the Topics page for Forum "Funding methodology"
    And I should see "Topic was successfully created"
    And I should see " Locating Grants in todays e..."
    And I should see "Jane Smith"

    When I follow "Edit"
    And I fill in "Name" with "todays economic impact on grants"
    And I press "Update"

    Then I should be redirected to the Topics page for Forum "Funding methodology"
    And I should see "Topic was successfully updated"
    And I should see "todays economic impact on g..."
     
    When I follow "todays economic impact on g..."
    And I follow "Add Comment"
    And I fill in "topic_comment_attributes_content" with "Grants in the East have become rare"
    And I press "Add Comment"

    Then I should be redirected to the "todays economic impact on grants" topic page for Forum "Funding methodology"
    And I should see "todays economic impact on grants"
    And I should see "Grants in the East have become rare"

  Scenario: Create a topic and verify that others can not edit the topic and its comments
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Locating Grants" to forum "Funding methodology"

    When I am logged in as "harry.simon@example.com"
    And I go to the Forums page
    Then I should not see "Edit"

  Scenario: Place textile text into a comment and verify that it is being html encoded
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |
    
    When I go to the Forums page
    And I follow "Measuring Fulfillment"
    And I fill in "Comment" with "*strong words* and _emphasized words_"
    And I press "Add Comment"
    # Unfortunely webrat filters out html tags so the redcloth html encoding can not be verified here 
    Then I should see "strong words and emphasized words" 
    
  Scenario: Editing forum topics concurrently to another admin editing the same forum topic
    Given I am logged in as "joe.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | joe.smith@example.com, jim.smith@example.com |
    When I go to the Forums page
    And I follow "Grant Capturing"
    And I follow "Edit"
    And I fill in "Name" with "Measuring Reward"

    Given session name is "admin session"
    And I am logged in as "joe.smith@example.com"
    When I go to the Forums page
    And I follow "Grant Capturing"
    And I follow "Edit"
    And I fill in "Name" with "Measuring Time"
    And I press "Update"
    Then I should see "Topic was successfully updated."

    Given session name is "default"
    And I press "Update"
    Then I should see "Another user recently updated the same topic. Please try again." within ".error"
    And I should be redirected to the "Measuring Time" edit topic page for Forum "Grant Capturing"
    When I fill in "Name" with "Measuring Reward"
    And I press "Update"
    Then I should see "Topic was successfully updated."
    When I go to the Forums page
    Then I should see "Measuring Reward"

  Scenario: Editing forum comments concurrently to another admin editing the same forum topic
    Given I am logged in as "joe.smith@example.com"
    And I have the comment "Totally!" to topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | joe.smith@example.com, jim.smith@example.com |
    When I go to the Forums page
    And I follow "Grant Capturing"
    And I follow "Edit"
    And I fill in "Comment" with "Sometimes."
    And I check "Update this"

    Given session name is "admin session"
    And I am logged in as "joe.smith@example.com"
    When I go to the Forums page
    And I follow "Grant Capturing"
    And I follow "Edit"
    And I fill in "Comment" with "Not really."
    And I check "Update this"
    And I press "Update Comment"
    Then I should see "Comments were successfully updated."

    Given session name is "default"
    And I press "Update Comment"
    Then I should see "This topic was recently changed by another user. Please try again." within ".error"
    And I should be redirected to the "Measuring Fulfillment" edit topic page for Forum "Grant Capturing"
    When I fill in "Comment" with "Sometimes."
    And I check "Update this"
    And I press "Update Comment"
    Then I should see "Comments were successfully updated."
    When I go to the Forums page
    Then I follow "Measuring Fulfillment"
    Then I should see "Sometimes."
