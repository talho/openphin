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
      | John Smith      | john.smith@example.com     | Health Officer  | Dallas County  |
      | Brian Simms     | brian.simms@example.com    | Epidemiologist  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com    | Public          | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com    | Health Officer  | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com   | Epidemiologist  | Wise County    |
      | Jason Phipps    | jason.phipps@example.com   | WMD Coordinator | Potter County  |
      | Dan Morrison    | dan.morrison@example.com   | Health Officer  | Ottawa County  | 
      | Brian Ryckbost  | brian.ryckbost@example.com | Health Officer  | Tarrant County |
      
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |  
    And the following users belong to the Red Cross:
      | John Smith | Ed McGuyver | Jason Phipps | Dan Morrison | Brian Ryckbost |
      
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the Alerts page
    And I follow "New Alert"

  Scenario: Sending an alert directly to a user
    When I fill out the alert form with:
      | People   | Keith Gaddis                                 |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Severity | Moderate                                     |
      | Status   | Actual                                       |
      | Acknowledge | <unchecked>                               |
      | Communication methods | E-mail                          |
      | Delivery Time | 15 minutes                              |
      
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And "keith.gaddis@example.com" should receive the email:
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |

  Scenario: Previewing an alert
    When I fill out the alert form with:
      | Jurisdictions | Dallas County, Potter County            |
      | Roles | Health Officer, Epidemiologist                  |
      | Organizations | Red Cross                               |
      | People   | Keith Gaddis                                 |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Severity | Moderate                                     |
      | Status   | Actual                                       |
      | Acknowledge | <unchecked>                               |
      | Communication methods | E-mail                          |
      | Delivery Time | 60 minutes                              |
    
    And I press "Preview Message"
    Then I see WTF is going on
    And I should see a preview of the message with:
      | Jurisdictions | Dallas County, Potter County            |
      | Roles | Health Officer, Epidemiologist                  |
      | Organizations | Red Cross                               |
      | People   | Keith Gaddis                                 |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Severity | Moderate                                     |
      | Status   | Actual                                       |
      | Acknowledge | No                                        |
      | Communication methods | E-mail                          |
      | Delivery Time | 60 minutes                              |
    
    When I press "Edit"
    And I make changes to the alert form with:
      | Title    | Something Different |
    And I press "Preview Message"
    Then I should see a preview of the message with:
      | Jurisdictions | Dallas County, Potter County            |
      | Roles | Health Officer, Epidemiologist                  |
      | Organizations | Red Cross                               |
      | People   | Keith Gaddis                                 |
      | Title    | Something Different                          |
      | Message  | For more details, keep on reading...         |
      | Severity | Moderate                                     |
      | Status   | Actual                                       |
      | Acknowledge | No                                        |
      | Communication methods | E-mail                          |
      | Delivery Time | 60 minutes                              |

  Scenario: Sending an alert to specific users sends alerts to each user
    When I fill out the alert form with:
      | People | Keith Gaddis, Dan Morrison |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
    
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People       | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |

  Scenario: Sending an alert with specified Jurisdictions sends to all users within those Jurisdictions
    When I fill out the alert form with:
      | Jurisdictions | Dallas County |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
  
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |    

  Scenario: Sending an alert with specified Jurisdictions/Roles scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Dallas County, Tarrant County |
      | Roles         | Health Officer |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
            
  Scenario: Sending an alert to an Jurisdictions/Organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Dallas County |
      | Organizations | Red Cross |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
  
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People        | john.smith@example.com, ed.mcguyver@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
      
  Scenario: Sending an alert to an Jurisdictions/Organizations when the organization contains sub-organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Texas |
      | Organizations | Red Cross |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
  
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People        | john.smith@example.com, ed.mcguyver@example.com, jason.phipps@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
            
  Scenario: Sending an alert to specific Jurisdictions/Roles/Organizations scopes who the alerts are sent to
    When I fill out the alert form with:
      | Jurisdictions | Tarrant County  |
      | Roles         | Health Officer |
      | Organization  | Red Cross |
      | Title  | H1N1 SNS push packs to be delivered tomorrow |
      | Message | For more details, keep on reading... |
      | Severity | Moderate |
      | Status | Actual |
      | Acknowledge | <unchecked> |
      | Communication methods | E-mail |
  
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And I should be on the alerts page
    And the following users should receive the email:
      | People        | brian.ryckbost@example.com |
      | subject       | Moderate Health Alert H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID: 1 |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    And "ethan.waldo@example.com" should not receive an email
    