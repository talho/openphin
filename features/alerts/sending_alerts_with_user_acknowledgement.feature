Feature: Acknowledging an alert

  Background:
   Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the dashboard page
    And I follow "Send an Alert"
 
  Scenario: Acknowledging an alert through an email with signing in
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Acknowledge | <checked> |
      | Communication methods | E-mail |
      
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    When delayed jobs are processed
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains alert acknowledgment link | |

    When I sign out
    And I log in as "keith.gaddis@example.com"
    And I follow the acknowledge alert link
    Then I should see "Successfully acknowledged alert: H1N1 SNS push packs to be delivered tomorrow"
    And the alert should be acknowledged
  
  Scenario: Acknowledging an alert through an email without signing in
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Acknowledge | <checked> |
      | Communication methods | E-mail |

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    When delayed jobs are processed
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains alert acknowledgment link | |

    When I sign out
    And I follow the acknowledge alert link
    Then I should see "Successfully acknowledged alert: H1N1 SNS push packs to be delivered tomorrow"
    And the alert should be acknowledged
    
  Scenario: A user cannot acknowledge an sensitive alert through an email without signing in
     When I fill out the alert form with:
       | People | Keith Gaddis |
       | Title  | H1N1 SNS push packs to be delivered tomorrow |
       | Acknowledge | <checked> |
       | Sensitive | <checked> |
       | Communication methods | E-mail |

     And I press "Preview Message"
     Then I should see a preview of the message

     When I press "Send"
     Then I should see "Successfully sent the alert"
     When delayed jobs are processed
     And "keith.gaddis@example.com" should receive the email:
       | subject       | Health Alert from Dallas County |
       | body does not contain alert acknowledgment link | |

     When I sign out
     And I follow the acknowledge alert link
     Then I should see "You are not authorized"
     And the alert should not be acknowledged

     Scenario: Acknowledging an alert through phone
       Given I am logged in as "keith.gaddis@example.com"
       When I go to the edit profile page
       And I select "Phone" from "Device Type"
       And I fill in "Phone" with "2105551212"
       And I press "Save"
       Then I should see "Profile information saved."
       When I go to the edit profile page
       Then I should see "2105551212"
       And I should have a phone device with the phone "2105551212"
       And I sign out
    
       Given I log in as "john.smith@example.com"
       And I am allowed to send alerts
       When I go to the dashboard page
       And I follow "Send an Alert"
       When I fill out the alert form with:
         | People | Keith Gaddis |
         | Title  | H1N1 SNS push packs to be delivered tomorrow |
         | Short Message | Chicken pox outbreak |
         | Severity | Moderate |
         | Status | Actual |
         | Acknowledge | <checked> |
         | Communication methods | Phone |
         | Sensitive | <unchecked> |
      
       And I press "Preview Message"
       Then I should see a preview of the message
    
       When I press "Send"
       Then I should see "Successfully sent the alert"
       And I sign out

       When delayed jobs are processed
       Then the following phone calls should be made:
         | phone        | message              |
         | 2105551212 | Chicken pox outbreak |
       
       When I acknowledge the phone message for "H1N1 SNS push packs to be delivered tomorrow"
       And delayed jobs are processed
       And I log in as "keith.gaddis@example.com"

       When I am on the dashboard page
       Then I can see the alert summary for "H1N1 SNS push packs to be delivered tomorrow"
       And I should not see an "Acknowledge" button
       But I should see "Acknowledge: Yes"