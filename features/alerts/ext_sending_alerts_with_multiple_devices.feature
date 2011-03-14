Feature: Sending alerts to multiple devices

  In order to be notified of an alert
  As a user
  I want people to be able to send alerts on all supported devices

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com    | Health Alert and Communications Coordinator | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com  | Epidemiologist                              | Wise County    |
      | Joe Black       | joe.black@example.com     | Epidemiologist                              | Potter County  |
      | Henry Frank     | henry.frank@example.com   | Public Relations                            | Bell County    |
      | Martin Gons     | martin.gons@example.com   | Chairopractor                               | Travis County  |
      | George Strait   | george.strait@example.com | Registered Nurse                            | Bell County    |
    And keith.gaddis@example.com has the following devices:
      | SMS   | 5125551245 |
      | Phone | 5125551235 |
      | Blackberry | 246D6BA3 |
    And joe.black@example.com has the following devices:
      | Phone | 5125551236 |
    And henry.frank@example.com has the following devices:
      | SMS   | 5125551247 |
    And martin.gons@example.com has the following devices:
      | Blackberry | 246D6BA6 |
    And george.strait@example.com has the following devices:
      | Phone | 5125551239 |
      | Blackberry | 246D6BA7 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to users with multiple devices
    Given I log in as "john.smith@example.com"
    And I am allowed to send alerts
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Short Message" with "Chicken pox outbreak"
    And I check "Phone"
    And I check "SMS"
    And I check "Blackberry"
    And I fill in "Caller ID" with "4114114111"

    And I select the following alert audience:
      | name          | type |
      | Keith Gaddis  | User |
      | Joe Black     | User |
      | Henry Frank   | User |
      | Martin Gons   | User |
      | George Strait | User |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                                                  |
      | 5125551235 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 5125551236 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 5125551239 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |

    When delayed jobs are processed
    Then the following SMS calls should be made:
      | sms          | message              |
      | 15125551245  | Chicken pox outbreak |
      | 15125551247  | Chicken pox outbreak |

    And the following Blackberry calls should be made:
       | blackberry    | message              |
       | 246D6BA3      | Chicken pox outbreak |
       | 246D6BA6      | Chicken pox outbreak |
       | 246D6BA7      | Chicken pox outbreak |

    And the following users should receive the alert email:
      | People        |  keith.gaddis@example.com, joe.black@example.com, henry.frank@example.com, martin.gons@example.com, george.strait@example.com |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow                                                                           |
