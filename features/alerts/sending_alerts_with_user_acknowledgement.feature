Feature: Acknowledging an alert

  Background:
   Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"
 
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
      | subject       | Health Alert from Dallas County |
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
      | subject       | Health Alert from Dallas County |
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
  