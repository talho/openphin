Feature: Alert Preview Audience Calculation
  In order to prevent accidentally-huge audiences
  As an alerter
  I can see an accurate total audience size on the Alert Preview page.

  # these tests are intentionally avoiding the three-deep nesting usually seen in jurisdictions -
  # This is only due to capybara issues with the tree selector.   This should be corrected with the EXT redesign.
  Background:
    Given the following entities exists:
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Epidemiologist                              |
      | Role         | Phantom                                     |
    And Federal is the parent jurisdiction of:
      | Texas | Michigan |          
    And Michigan is the parent jurisdiction of:
      | Potter County |
    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County |
    And the following users exist:
      | Fed Hacc        | fed.hacc@example.com    | Health Alert and Communications Coordinator | Federal        |
      | Tex Hacc        | tex.hacc@example.com    | Health Alert and Communications Coordinator | Texas          |
      | Mic Hacc        | mic.hacc@example.com    | Health Alert and Communications Coordinator | Michigan       |
      | Dal Hacc        | dal.hacc@example.com    | Health Alert and Communications Coordinator | Dallas County  |
      | Dal Epid        | dal.epid@example.com    | Epidemiologist                              | Dallas County  |
      | Tar Hacc        | tar.hacc@example.com    | Health Alert and Communications Coordinator | Tarrant County |
      | Tar Epid        | tar.epid@example.com    | Epidemiologist                              | Tarrant County |
      | Pot Hacc        | pot.hacc@example.com    | Health Alert and Communications Coordinator | Potter County  |
      | Pot Epid        | pot.epid@example.com    | Epidemiologist                              | Potter County  |
    And the role "Health Alert and Communications Coordinator" is an alerter

  Scenario: A non-cross-jurisdictional alert is sent within a single jurisdiction
    Given I am logged in as "dal.hacc@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"

    And I fill out the alert form with:
      | Jurisdictions         | Dallas County                                |
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | There is a Chicken pox outbreak in the area  |
      | Short Message         | Chicken pox outbreak                         |
      | Severity              | Moderate                                     |
      | Status                | Test                                         |
      | Acknowledge           | None                                         |
      | Communication methods | E-mail                                       |
      | Disable Cross-Jurisdictional alerting? | <checked>                   |
    And I press "Preview"
    Then I should see "# of Recipients: 2"

  Scenario: A cross-jurisdictional alert is sent to a sibling jurisdiction
    Given I am logged in as "dal.hacc@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | There is a Chicken pox outbreak in the area  |
      | Short Message         | Chicken pox outbreak                         |
      | Severity              | Moderate                                     |
      | Status                | Test                                         |
      | Acknowledge           | None                                         |
      | Communication methods | E-mail                                       |
      | Disable Cross-Jurisdictional alerting? | <unchecked>                 |
      | Jurisdictions         | Tarrant County                               |
    And I press "Preview"
    Then I should see "# of Recipients: 4"

  Scenario: A cross-jurisdictional alert is sent to a cousin jurisdiction
    Given I am logged in as "dal.hacc@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | There is a Chicken pox outbreak in the area  |
      | Short Message         | Chicken pox outbreak                         |
      | Severity              | Moderate                                     |
      | Status                | Test                                         |
      | Acknowledge           | None                                         |
      | Communication methods | E-mail                                       |
      | Disable Cross-Jurisdictional alerting? | <unchecked>                 |
      | Jurisdictions         | Tarrant County, Potter County                |
    And I press "Preview"
    And I press "Send this Alert"
    And delayed jobs are processed
    And I follow "Alert Log and Reporting"
    And I follow "View"
    Then I should see "# of Recipients: 8"

  Scenario: A cross-jurisdictional alert is sent to a role
    Given I am logged in as "dal.hacc@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | There is a Chicken pox outbreak in the area  |
      | Short Message         | Chicken pox outbreak                         |
      | Severity              | Moderate                                     |
      | Status                | Test                                         |
      | Acknowledge           | None                                         |
      | Communication methods | E-mail                                       |
      | Disable Cross-Jurisdictional alerting? | <unchecked>                 |
      | Roles                 | Epidemiologist                               |
    And I press "Preview"
    And I press "Send this Alert"
    And delayed jobs are processed
    And I follow "Alert Log and Reporting"
    And I follow "View"
    Then I should see "# of Recipients: 9"

  Scenario: An alert is sent to nobody
    Given I am logged in as "dal.hacc@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"
    And I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | There is a Chicken pox outbreak in the area  |
      | Short Message         | Chicken pox outbreak                         |
      | Severity              | Moderate                                     |
      | Status                | Test                                         |
      | Acknowledge           | None                                         |
      | Communication methods | E-mail                                       |
      | Disable Cross-Jurisdictional alerting? | <unchecked>                 |
      | Roles                 | Phantom                                      |
    And I press "Preview"
    And I press "Send this Alert"
    And delayed jobs are processed
    And I follow "Alert Log and Reporting"
    And I follow "View"
    Then I should see "# of Recipients: 0"
