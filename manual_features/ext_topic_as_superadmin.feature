Feature: Managing a topic as a super admin

  In order to moderate topics in the forum
  As a super-administrator
  I would like to be able to edit and delete comments from the topic view

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas          |
      | Jurisdiction | Dallas County  |
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
    And a role named Health Officer
    And the user "Jane Smith" with the email "jane.smith@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Jeff Brown" with the email "joe.black@example.com" has the role "Health Officer" in "Dallas County"
    And the user "Joe Smith" with the email "joe.smith@example.com" has the role "SuperAdmin" in "Texas"
    And I am logged in as "jane.smith@example.com"
    And I have the comment "Walmart claims 100% fulfillment" to topic "Measuring Fulfillment" to forum "Grant Capturing"
    When I am logged in as "joe.smith@example.com"
    And I navigate to "Forums"
    And I select the "Grant Capturing" grid row
    And I click inlineLink "Measuring Fulfillment"
    Then the "Measuring Fulfillment" tab should be open

  Scenario: Edit as a super_admin an existing comment to a topic posted by someone else
    When I click topic-edit-comment-button on the "Walmart claims 100% fulfillment" grid row
    And I fill in "topic[comment_attributes][content]" with "Look at who is counting"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "Look at who is counting"
    And I should not see "Walmart claims 100% fulfillment"

  Scenario: Edit as a super_admin the original topic
    When I click topic-edit-comment-button on the "Topic desc" grid row
    And I fill in "topic[comment_attributes][content]" with "This is a new topic description"
    And I press "Save"
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should see "This is a new topic description"
    And I should not see "Topic desc" within ".x-grid3"


  Scenario: Delete as a super_admin an existing comment to a topic posted by someone else
    When I will confirm on next step
    And I click topic-delete-comment-button on the "Walmart claims 100% fulfillment" grid row
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then I should not see "Walmart claims 100% fulfillment"


  Scenario: Delete as a super_admin an existing comment to a topic posted by someone else
    When I will confirm on next step
    And I click topic-delete-comment-button on the "Topic desc" grid row
    And I wait for the "Saving..." mask to go away
    And I wait for the "Loading..." mask to go away
    Then the "Forums" tab should be open and active
    And the "Measuring Fulfillment" tab should not be open
    And I should not see "Measuring Fulfillment"