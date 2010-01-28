
Feature: Creating a topic to a forum as a user

In order to allow for discussion of various and possibly arbitrary topics
As a user with access
I should be able to create topics to forums and place comments to these topics

  Background:
    Given an organization named Red Cross
    And the following entities exist:
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


  Scenario: Create a topic and edit the topic as the poster
    Given I am logged in as "jane.smith@example.com"
    And I have the forum named "Funding methodology"
    
    When I go to the Forums page
    And I follow "Funding methodology"
    And I follow "New topic"
    And I fill in "Name" with "Locating Grants in todays economy"
    And I press "Create"

    Then I should be redirected to the Topics page for Forum "Funding methodology"
    And I should see "Topic was successfully created"
    And I should see "Locating Grants in todays economy"
    And I should see "Jane Smith"

    When I follow "Edit"
    And I fill in "Name" with "todays economic impact on grants"
    And I press "Update"

    Then I should be redirected to the Topics page for Forum "Funding methodology"
    And I should see "Topic was successfully updated"
    And I should see "todays economic impact on grants"
     
    When I follow "todays economic impact on grants"
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
    
    When I go to the Forums page
    And I follow "Measuring Fulfillment"
    And I fill in "Comment" with "*strong words* and _emphasized words_"
    And I press "Add Comment"
    # Unfortunely webrat filters out html tags so the redcloth html encoding can not be verified here 
    Then I should see "strong words and emphasized words" 
    


