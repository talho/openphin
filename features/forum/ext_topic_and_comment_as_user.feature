
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
    And  Health Officer is a non public role
    And the following users exist:
      | Jane Smith  | jane.smith@example.com  | Public | Dallas County |
      | Harry Simon | harry.simon@example.com | Public | Dallas County |
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Harry Simon" with the email "harry.simon@example.com" has the role "Health Officer" in "Dallas County"


  Scenario: View own topic and a topic created by another user
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com, harry.simon@example.com |
    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open and active
    And I wait for the "Loading..." mask to go away
    Then I should see "Add Reply"
    And I should not see "Delete"
    And I should see "Edit"
    And I should see "Quote"

    When I navigate to "Sign Out"
    And I am logged in as "harry.simon@example.com"
    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open and active
    And I wait for the "Loading..." mask to go away
    Then I should see "Add Reply"
    And I should not see "Delete"
    And I should not see "Edit"
    And I should see "Quote"


  Scenario: Edit, quote, and reply to own topic
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |
    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open

    When I click topic-edit-comment-button "Edit"
    Then the "Edit Comment" window should be open
    When I fill in "topic[comment_attributes][content]" with "Desc for my topic"
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Desc for my topic"
    And I should see "Measuring Fulfillment"
    And I should see "Jane Smith"

    When I click topic-quote-comment-button on the "Desc for my topic" grid row
    Then the "New Comment" window should be open
    And the "topic[comment_attributes][content]" field should contain "bq.. __Originally posted by: Jane Smith__\n\nDesc for my topic\n\np. "

    When I close the active ext window
    And I press "Add Reply"
    Then the "New Comment" window should be open
    When I fill in "topic[comment_attributes][content]" with "This is a response"
    
    And I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "This is a response" in grid row 2

  Scenario: Reply to someone else's topic and quote someone else's reply
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com, harry.simon@example.com |

    Given I am logged in as "harry.simon@example.com"
    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open

    And I press "Add Reply"
    When I fill in "topic[comment_attributes][content]" with "This is a response"
    When I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "This is a response" in grid row 2

    When I navigate to "Sign Out"
    And I am logged in as "jane.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open
    When I wait for the "Loading..." mask to go away

    Then I should not see "Edit" in grid row 2
    When I click topic-quote-comment-button on the "This is a response" grid row
    Then the "topic[comment_attributes][content]" field should contain "bq.. __Originally posted by: Harry Simon__\n\nThis is a response\n\np. "
    When I press "Save"

    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Originally posted by: Harry Simon" in grid row 3
    Then I should see "This is a response" in grid row 3


  Scenario: Place textile text into a comment and verify that it is being html encoded
    Given I am logged in as "jane.smith@example.com"
    And I have the topic "Measuring Fulfillment" to forum "Grant Capturing"
    And the forum "Grant Capturing" has the following audience:
      | Users | jane.smith@example.com  |

    When I go to the ext dashboard page
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"

    And I press "Add Reply"
    And I fill in "topic[comment_attributes][content]" with "*strong words* and _emphasized words_"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see html "<strong>strong words</strong> and <em>emphasized words</em>"

