Feature: Sending alerts across jurisdictions
  In order to meet PHIN obligations by keeping HAN Coordinators informed
  As an alerter
  I automatically inform HAN Coordinators of cross-jurisdictional alerts
  
  Background:
    Given the following entities exists:
      | Jurisdiction | Tarrant County                              |
      | Jurisdiction | Wise County                                 |
      | Jurisdiction | Potter County                               |
      | Jurisdiction | Dallas County                               |
      | Jurisdiction | Ottawa County                               |
      | Jurisdiction | Texas                                       |
      | Jurisdiction | Michigan                                    |
      | Role         | Health Officer                              |
      | Role         | Health Alert and Communications Coordinator |
    And the following users exist:
      | Ethan Waldo     | ethan.waldo@example.com    | Health Alert and Communications Coordinator | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com   | Health Alert and Communications Coordinator | Wise County    |
      | Jason Phipps    | jason.phipps@example.com   | Health Alert and Communications Coordinator | Potter County  |
      | Dan Morrison    | dan.morrison@example.com   | Health Alert and Communications Coordinator | Ottawa County  | 
      | Zach Dennis     | zach.dennis@example.com | Health Officer | Dallas County |
      | Brandon Keepers | brandon.keepers@example.com | Health Alert and Communications Coordinator | Texas |
      | Brian Ryckbost | brian.ryckbost@example.com | Health Officer | Texas |
    
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |  
    And Michigan is the parent jurisdiction of:
      | Ottawa County |
    
    And the role "Health Officer" is an alerter
    And I am logged in as "zach.dennis@example.com"
    And I am allowed to send alerts
    When I go to the han page
    And I follow "Send an Alert"

  Scenario: Sending an alert to sibling jurisdictions
    When I fill out the alert "Details" form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | For more details, keep on reading...         |
      | Short Message         | For more details, keep on reading...         |
      | Communication methods | E-mail                                       |
    And I press "Audience"
    And I fill out the alert "Audience" form with:
      | Roles         | Health Officer      |
      | Jurisdictions | Tarrant County, Wise County |
    And I press "Preview Message"
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And the following users should receive the alert email:
      | People        | ethan.waldo@example.com, keith.gaddis@example.com |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
    And the following users should not receive any alert emails
      | roles         | Potter County / Health Alert and Communications Coordinator |
      | roles         | Ottawa County / Health Alert and Communications Coordinator |
      | roles         | Texas / Health Alert and Communications Coordinator |  
      | emails        | jason.phipps@example.com, dan.morrison@example.com, brandon.keepers@example.com |
    
  Scenario: Sending an alert to a parent jurisdiction
    When I fill out the alert "Details" form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | For more details, keep on reading...         |
      | Short Message         | For more details, keep on reading...         |
      | Communication methods | E-mail                                       |
    And I press "Audience"
    And I fill out the alert "Audience" form with:
      | Roles         | Health Officer      |
      | Jurisdictions | Texas |
    And I press "Preview Message"
    When I press "Send"
    Then I should see "Successfully sent the alert"
    And the following users should receive the alert email:
      | People        | brandon.keepers@example.com |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
    And the following users should not receive any alert emails
      | roles         | Potter County / Health Alert and Communications Coordinator |
      | roles         | Ottawa County / Health Alert and Communications Coordinator |
      | roles         | Tarrant County / Health Alert and Communications Coordinator |
      | roles         | Potter County / Health Alert and Communications Coordinator |
      | emails        | ethan.waldo@example.com, keith.gaddis@example.com, jason.phipps@example.com, dan.morrison@example.com |    
        
  Scenario: Sending an alert to a cousin jurisdiction
    When I fill out the alert "Details" form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | For more details, keep on reading...         |
      | Short Message         | For more details, keep on reading...         |
      | Communication methods | E-mail                                       |
    And I press "Audience"
    And I fill out the alert "Audience" form with:
      | Roles         | Health Officer      |
      | Jurisdictions | Ottawa County |
    And I press "Preview Message"
    When I press "Send"
    Then I should see "Successfully sent the alert"  
    And the following users should receive the alert email:
      | People        | dan.morrison@example.com, brandon.keepers@example.com |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
    And the following users should not receive any alert emails
      | roles         | Potter County / Health Alert and Communications Coordinator |
      | roles         | Tarrant County / Health Alert and Communications Coordinator |
      | roles         | Potter County / Health Alert and Communications Coordinator |
      | emails        | ethan.waldo@example.com, keith.gaddis@example.com, jason.phipps@example.com |