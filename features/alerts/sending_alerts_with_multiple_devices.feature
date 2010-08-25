Feature: Sending alerts to multiple devices

  In order to be notified of an alert
  As a user
  I want people to be able to send alerts on all supported devices
  
  Background: 
    Given the following users exist: 
      | John Smith      | john.smith@example.com    | Health Officer   | Dallas County  | 
      | Keith Gaddis    | keith.gaddis@example.com  | Epidemiologist   | Wise County    | 
      | Joe Black       | joe.black@example.com     | Epidemiologist   | Potter County  | 
      | Henry Frank     | henry.frank@example.com   | Public Relations | Bell County    | 
      | Martin Gons     | martin.gons@example.com   | Chairopractor    | Travis County  | 
      | George Strait   | george.strait@example.com | Registered Nurse | Bell County    | 
    And keith.gaddis@example.com has the following devices:
      | SMS   | 5125551245 |
      | Phone | 5125551235 |
      | Blackberry | 246D6BA3 |
    And joe.black@example.com has the following devices:
      | Phone | 5125551236 |
    And henry.frank@example.com  has the following devices:
      | SMS   | 5125551247 |
    And martin.gons@example.com  has the following devices:
      | Blackberry | 246D6BA6 |
    And george.strait@example.com  has the following devices:
      | Phone | 5125551239 |
      | Blackberry | 246D6BA7 |      
    And the role "Health Officer" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to users with multiple devices
    Given I am logged in as "keith.gaddis@example.com"
      When I go to the edit profile page
      Then I should have a phone device with the phone "5125551235"
      Then I should have a SMS device with the SMS number "5125551245"
      Then I should have a Blackberry device with the Blackberry number "246D6BA3"
      Then I should have an Email device with the Email address "keith.gaddis@example.com"
      And I sign out
     
    Given I am logged in as "joe.black@example.com"
      When I go to the edit profile page
      Then I should have a phone device with the phone "5125551236"
      And I sign out
      
     Given I am logged in as "henry.frank@example.com"
      When I go to the edit profile page
      Then I should have a SMS device with the SMS number "5125551247"
      And I sign out

     Given I am logged in as "martin.gons@example.com"
      When I go to the edit profile page
      Then I should have a Blackberry device with the Blackberry number "246D6BA6"
      And I sign out

     Given I am logged in as "george.strait@example.com"
       When I go to the edit profile page
       Then I should have a phone device with the phone "5125551239"
       Then I should have a Blackberry device with the Blackberry number "246D6BA7"
       And I sign out

    Given I log in as "john.smith@example.com"
     And I am allowed to send alerts
     When I go to the HAN
     And I follow "Send an Alert"
     And I fill out the alert form with:
       | People | Keith Gaddis, Joe Black, Henry Frank, Martin Gons, George Strait |
       | Title  | H1N1 SNS push packs to be delivered tomorrow |
       | Message | There is a Chicken pox outbreak in the area |
       | Short Message | Chicken pox outbreak |
       | Severity | Moderate |
       | Status | Actual |
       | Acknowledge | None |
       | Communication methods | Phone, SMS, E-mail, Blackberry |
       | Sensitive | <unchecked> |
    
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
