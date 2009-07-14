Feature: Creating and sending alerts

  In order to notify others in a timely fashion
  As a user
  I can create and send alerts

  Background: 
    Given the following entities exists:
      | Organization | Red Cross             |
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Jurisdiction | Wise County           |
      | Jurisdiction | Potter County         |
      | Jurisdiction | Texas                 |
      | Role         | Health Officer        |
      | Role         | Immunization Director |
      | Role         | Epidemiologist        |
      | Role         | WMD Coordinator       |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Brian Simms     | brian.simms@example.com  | Epidemiologist  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com  | Public          | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com  | Health Officer  | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist  | Wise County    |
      | Jason Phipps    | jason.phipps@example.com | WMD Coordinator | Potter County  |
      | Dan Morrison    | dan.morrison@example.com | Health Officer  | Ottawa County  | 
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |  
    And Michigan is the parent jurisdiction of:
      | Ottawa County |
    And the following users belong to the Red Cross:
      | John Smith | Ed McGuyver | Jason Phipps | Dan Morrison |
      
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"

  Scenario: Sending an alert directly to a user
    When I fill out the alert form with:
      | People | Keith Gaddis |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
      
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |

  Scenario: Sending an alert to specific users sends alerts to each user
    When I fill out the alert form with:
      | People | Keith Gaddis, Dan Morrison |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
      
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People       | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |

  Scenario: Sending an alert with specified Jurisdictions sends to all users within those Jurisdictions
    When I fill out the alert form with:
      | Jurisdictions | Dallas County |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
  
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |

  Scenario: Sending an alert with specified Jurisdictions/Roles scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Dallas County, Tarrant County |
      | Roles         | Health Officer |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
  
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |
      
  Scenario: Sending an alert to an Jurisdictions/Organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Dallas County |
      | Organizations | Red Cross |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
  
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People        | john.smith@example.com, ed.mcguyver@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |

  Scenario: Sending an alert to an Jurisdictions/Organizations when the organization contains sub-organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Texas |
      | Organizations | Red Cross |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
  
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People        | john.smith@example.com, ed.mcguyver@example.com, jason.phipps@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |

      
  Scenario: Sending an alert to specific Jurisdictions/Roles/Organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdiction  | Tarrant County  |
      | Roles         | Health Officer |
      | Organization  | Texas |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Body   | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledgement | <unchecked> |
      | Communication methods | Email |
  
    And I click "Preview Message"
    Then I should see a preview of the message

    When I click "Send"
    Then I should see "Successfully sent the alert"
    And I should be at the logs page
    And the following users should receive the email:
      | People        | ethan.waldo@example.com |
      | subject       | Moderate Health Alert from Dallas County : John Smith : Health Officer |
      | body contains | Status: Actual |
      | body contains | Type: Alert    |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | For more details, keep on reading... |
  