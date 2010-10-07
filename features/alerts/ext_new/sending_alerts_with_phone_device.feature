@ext
Feature: Sending alerts to phones

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my phone

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                               | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And "keith.gaddis@example.com" has the following devices:
      | phone | 2105551212 |
      | phone | 2105551213 |
    And delayed jobs are processed

  Scenario: Sending alerts to phone devices
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send a HAN Alert"
    When I fill in the ext alert defaults
    And I check "Phone"
    And I fill in "Caller ID" with "4114114111"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak"
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I send the alert

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

  Scenario: Sending alerts to phone devices with acknowledgment
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send a HAN Alert"
    When I fill in the ext alert defaults
    And I uncheck "E-mail"
    And I check "Phone"
    And I fill in "Caller ID" with "4114114111"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak"
    And I select "Normal" from ext combo "Acknowledge"
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I send the alert

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

    # legacy code since we haven't converted the alert log to EXT yet
    When I go to the alert log
    And I follow "More"
    Then I can see the device alert acknowledgement rate for "H1N1 SNS push packs to be delivered tomorrow" in "Phone" is 0%
    #end legacy code

  Scenario: Sending alerts to users with multiple phone devices
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send an Alert"
    When I fill in the ext alert defaults
    And I check "Phone"
    And I fill in "Caller ID" with "4114114111"
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak"
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I send the alert

    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message       |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 2105551213 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

  Scenario: Sending alerts with call down
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the ext dashboard page
    And I navigate to "HAN > Send a HAN Alert"
    When I fill in the ext alert defaults
    And I check "Phone"
    And I fill in "Caller ID" with "4114114111"
    And I select "Moderate" from ext combo "Severity"
    When I select "Advanced" from ext combo "Acknowledge"
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I press "+ Add another response"
    And I fill in the following:
      | Short Message    | Chicken pox outbreak                         |
      | Alert Response 1 | if you can respond within 15 minutes         |
      | Alert Response 2 | if you can respond within 30 minutes         |
      | Alert Response 3 | if you can respond within 1 hour             |
      | Alert Response 4 | if you can respond within 4 hours            |
      | Alert Response 5 | if you cannot respond                        |
    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
    And I send the alert
        
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  | call_down                            |
      | 2105551212 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area | if you can respond within 15 minutes |
    And the phone call should have 5 calldowns