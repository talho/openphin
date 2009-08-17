Feature: Sending cascading alerts
  In order to inform users on other systems
  As a user
  I can send alerts that are cascaded to other servers
  
  Background:
    Given the following entities exists:
      | Organization | Louisiana State Public Health Department |
      | Jurisdiction | Federal                                  |
      | Jurisdiction | Texas                                    |
      | Role         | Health Officer                           |
      | Role         | Immunization Director                    |
    And Louisiana State Public Health Department is a foreign Organization
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Officer  | Dallas County  |
      | Jason Phipps    | jason.phipps@example.com | WMD Coordinator | Potter County  |
    And Federal is the parent jurisdiction of:
      | Texas |  
    
    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the dashboard page
    And I follow "Send an Alert"

  Scenario: Sending a cascading alert
    When I fill out the alert form with:
      | Jurisdictions | Federal                                 |
      | Role         | Immunization Director                    |
      | Organization | Louisiana State Public Health Department |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Acknowledge | <unchecked>                               |
      | Communication methods | E-mail                          |
    
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "H1N1 SNS push packs to be delivered tomorrow" is sent to Louisiana State Public Health Department
  
  Scenario: Trying to send cascading alert that should not cascade
    When I fill out the alert form with:
      | Jurisdictions | Texas                                   |
      | Role         | Immunization Director                    |
      | Organization | Louisiana State Public Health Department |
      | Title    | H1N1 SNS push packs to be delivered tomorrow |
      | Message  | For more details, keep on reading...         |
      | Acknowledge | <unchecked>                               |
      | Communication methods | E-mail                          |

    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And no foreign alert "H1N1 SNS push packs to be delivered tomorrow" is sent to Louisiana State Public Health Department

  
  Scenario: Sending an update to a cascading alert
  Scenario: Sending a cancel to a cascading alert
  Scenario: Requiring acknowledgement to a cascading alert
