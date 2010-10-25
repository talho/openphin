

  Scenario: Edit as a super_admin an existing comment to a topic posted by someone else
    Given I am logged in as "jane.smith@example.com"
    And I have the comment "Walmart claims 100% fulfillment" to topic "Measuring Fulfillment" to forum "Grant Capturing"

    When I am logged in as "joe.smith@example.com"
    And I go to the Topics page for Forum "Grant Capturing"
    Then I should see "Measuring Fulfillment"

    When I follow "Edit"
    And I follow "Edit Comment"
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
    And I follow "Edit Comment"
    And I check "delete_comment_ids_"
    And I press "Update Comment"
    Then I should see "Comments were successfully updated"
    And I should be redirected to the "Measuring Fulfillment" topic page for Forum "Grant Capturing"
    And I should not see "Walmart claims 100% fulfillment"