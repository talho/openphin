Feature: Acknowledging an alert

  Background:
   Given the following users exist:
      | John Smith   | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County |
      | Keith Gaddis | keith.gaddis@example.com | Epidemiologist                              | Wise County   |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

  Scenario: Acknowledging an alert through an email with signing in
    When I fill in the following:
      | Title   | H1N1 SNS push packs to be delivered tomorrow |
      | Message | This is a message...                         |
    And I select "Normal" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I check "E-mail"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    Then the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains alert acknowledgment link | |

    # legacy code because we haven't converted the acknowledgement stuff to ext
    When I sign out
    And I log in as "keith.gaddis@example.com"
    And I follow the acknowledge alert link
    Then I should see "Successfully acknowledged alert: H1N1 SNS push packs to be delivered tomorrow"
    And the alert should be acknowledged
    # end legacy code: replace when acknowledgement is implemented

  Scenario: Acknowledging an alert through an email without signing in
    When I fill in the following:
      | Title   | H1N1 SNS push packs to be delivered tomorrow |
      | Message | This is a message...                         |
    And I select "Normal" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I check "E-mail"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains alert acknowledgment link | |

    # legacy code because we haven't converted the acknoledgement stuff to ext
    When I sign out
    And I follow the acknowledge alert link
    Then I should see "Successfully acknowledged alert: H1N1 SNS push packs to be delivered tomorrow"
    And the alert should be acknowledged
    # end legacy code: replace when acknowledgement is implemented

  Scenario: A user cannot acknowledge an sensitive alert through an email without signing in
    When I fill in the following:
      | Title   | H1N1 SNS push packs to be delivered tomorrow |
      | Message | This is a message...                         |
    And I select "Normal" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I check "E-mail"
    And I check "Sensitive (confidential)"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    When delayed jobs are processed
    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body does not contain alert acknowledgment link | |

    # legacy code because we haven't converted the acknowledgement stuff to ext
    When I sign out
    And I follow the acknowledge alert link
    Then I should see "You are not authorized"
    And the alert should not be acknowledged
    # end legacy code: replace when acknowledgement is implemented

  Scenario: Acknowledging an alert through phone
    When I sign out
    # legacy code because we haven't converted user profile to ext
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    # end legacy code

    Given I log in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I fill in the following:
      | Title         | H1N1 SNS push packs to be delivered tomorrow |
      | Message       | There is a Chicken pox outbreak in the area  |
      | Short Message | Chicken pox outbreak                         |
    And I select "Normal" from ext combo "Acknowledge"
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I select "Actual" from ext combo "Status"
    And I select "Moderate" from ext combo "Severity"
    And I check "Phone"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    And I sign out

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

    # legacy code because we haven't converted the acknowledgement stuff to ext
    When I acknowledge the phone message for "H1N1 SNS push packs to be delivered tomorrow"
    And delayed jobs are processed
    And I log in as "keith.gaddis@example.com"

    When I am on the HAN
    Then I can see the alert summary for "H1N1 SNS push packs to be delivered tomorrow"
    And I should not see an "Acknowledge" button
    But I should see "Acknowledge: Yes"
    # end legacy code: replace when acknowledgement is implemented

  Scenario: Acknowledging an alert through an email with signing in and call downs
    And I select "Advanced" from ext combo "Acknowledge"
    # add a 3rd response box
    And I press "+ Add another response"
    When I fill in the following:
      | Title            | H1N1 SNS push packs to be delivered tomorrow |
      | Message          | There is a Chicken pox outbreak in the area  |
      | Short Message    | Chicken pox outbreak                         |
      | Alert Response 1 | if you can call back within 15 minutes       |
      | Alert Response 2 | if you can call back within 30 minutes       |
      | Alert Response 3 | if you can call back within 45 minutes       |
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I select "Actual" from ext combo "Status"
    And I check "E-mail"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open

    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |

    # legacy code because we haven't converted the acknowledgement stuff to ext
    And I am logged in as "keith.gaddis@example.com"
    And I follow the acknowledge alert link "if you can call back within 30 minutes"
    Then I should see "Successfully acknowledged alert: H1N1 SNS push packs to be delivered tomorrow"
    And the alert should be acknowledged

    When I am on the HAN
    Then I can see the alert summary for "H1N1 SNS push packs to be delivered tomorrow"
    And I should see "Acknowledge: if you can call back within 30 minutes"

    #### make sure the double-ack error works
    And I follow the acknowledge alert link "if you can call back within 30 minutes"
    Then I should see "You may have already acknowledged the alert"
    # end legacy code: replace when acknowledgement is implemented

  Scenario: Acknowledging an alert through phone with call downs
    When I sign out
    # legacy code here because we have not update the user profile
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the edit profile page
    And I follow "Add Device"
    And I select "Phone" from "Device Type"
    And I fill in "Phone" with "2105551212"
    And I press "Save"
    Then I should see "Profile information saved."
    When I go to the edit profile page
    Then I should see "2105551212"
    And I should have a phone device with the phone "2105551212"
    And I sign out
    # end legacy code: replace when user profile has been updated to work in ext

    Given I log in as "john.smith@example.com"
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    And I select "Advanced" from ext combo "Acknowledge"
    When I fill in the following:
      | Title            | H1N1 SNS push packs to be delivered tomorrow |
      | Message          | There is a Chicken pox outbreak in the area  |
      | Short Message    | Chicken pox outbreak                         |
      | Alert Response 1 | if you can call back within 15 minutes       |
      | Alert Response 2 | if you can call back within 30 minutes       |
    And I select "Dallas County" from ext combo "Jurisdiction"
    And I select "Actual" from ext combo "Status"
    And I select "Moderate" from ext combo "Severity"
    And I check "Phone"

    And I click breadCrumbItem "Audience"
    And I select the following in the audience panel:
      | name         | type |
      | Keith Gaddis | User |
    And I click breadCrumbItem "Preview"
    Then I should have the "Preview" breadcrumb selected

    When I press "Send Alert"
    Then the "Alert Detail - H1N1 SNS push packs to be delivered tomorrow" tab should be open
    And the "Send Alert" tab should not be open
    
    And I sign out

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

    # legacy code because we haven't converted the acknoledgement stuff to ext
    When I acknowledge the phone message for "H1N1 SNS push packs to be delivered tomorrow" with "if you can respond within 15 minutes"
    And delayed jobs are processed
    And I log in as "keith.gaddis@example.com"

    When I am on the HAN
    Then I can see the alert summary for "H1N1 SNS push packs to be delivered tomorrow"
    And I should not see an "Acknowledge" button
    But I should see "Acknowledge: if you can respond within 15 minutes"
    # end legacy code: replace when acknowledgement is implemented