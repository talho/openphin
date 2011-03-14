Feature: Sending alerts to multiple devices

  In order to be notified of an alert
  As a user
  I want people to be able to send alerts on all supported devices
  
  Background: 
    Given the following entities exists:
      | Role                  | Health Alert and Communications Coordinator |
      | Role                  | Health Officer                              |
      | Role                  | Epidemiologist                              |
      | Role                  | Public Relations                            |
      | Role                  | Chiropractor                                |
      | Role                  | Registered Nurse                            |
      | Jurisdiction          | Potter County                               |
      | Jurisdiction          | Dallas County                               |
      | Jurisdiction          | Travis County                               |
      | Jurisdiction          | Bell County                                 |
      | Jurisdiction          | Wise County                                 |
    And the following users exist:
      | John Smith      | john.smith@example.com    | Health Officer   | Dallas County  |
      | Keith Gaddis    | keith.gaddis@example.com  | Epidemiologist   | Wise County    |
      | Joe Black       | joe.black@example.com     | Epidemiologist   | Potter County  |
      | Henry Frank     | henry.frank@example.com   | Public Relations | Bell County    |
      | Martin Gons     | martin.gons@example.com   | Chiropractor     | Travis County  |
      | George Strait   | george.strait@example.com | Registered Nurse | Bell County    |
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
    And the role "Health Officer" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to users with multiple devices
    Given I log in as "john.smith@example.com"
     And I am allowed to send alerts
     When I go to the HAN
     And I follow "Send an Alert"
     And I fill out the alert form with:
       | People                | Keith Gaddis, Joe Black, Henry Frank, Martin Gons, George Strait |
       | Title                 | H1N1 SNS push packs to be delivered tomorrow                     |
       | Message               | There is a Chicken pox outbreak in the area                      |
       | Short Message         | Chicken pox outbreak                                             |
       | Severity              | Moderate                                                         |
       | Status                | Actual                                                           |
       | Acknowledge           | None                                                             |
       | Communication methods | Phone, SMS, E-mail, Blackberry                                   |
       | Caller ID             | 1234567890                                                       |
       | Sensitive             | <unchecked>                                                      |
    
      And I press "Preview Message"
      Then I should see a preview of the message
      When I press "Send"
      Then I should see "Successfully sent the alert"
    
    When delayed jobs are processed
    Then the following phone calls should be made:
      | phone      | message                                                                                           |
      | 5125551235 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 5125551236 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      | 5125551239 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak in the area |
      
    When delayed jobs are processed  
    Then the following SMS calls should be made:
      | sms         | message              |
      | 15125551245  | Chicken pox outbreak |
      | 15125551247  | Chicken pox outbreak |
      
    And the following Blackberry calls should be made:
       | blackberry    | message              |
       | 246D6BA3      | Chicken pox outbreak |
       | 246D6BA6      | Chicken pox outbreak |
       | 246D6BA7      | Chicken pox outbreak |

    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com, joe.black@example.com, henry.frank@example.com, martin.gons@example.com, george.strait@example.com |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow | 
