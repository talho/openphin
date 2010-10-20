Feature: Sending alerts to multiple devices

  In order to be notified of an alert
  As a user
  I want people to be able to send alerts on all supported devices

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com    | Health Alert and Communications Coordinator | Dallas County  |
      | Anne Smith      | anne.smith@example.com    | Epidemiologist                              | Wise County    |
      | Joe Black       | joe.black@example.com     | Epidemiologist                              | Potter County  |
      | Henry Frank     | henry.frank@example.com   | Public Relations                            | Bell County    |
      | Martin Gons     | martin.gons@example.com   | Chairopractor                               | Travis County  |
      | George Strait   | george.strait@example.com | Registered Nurse                            | Bell County    |
    And anne.smith@example.com has the following devices:
      | SMS        | 5125551245 |
      | Phone      | 5125551235 |
      | Blackberry | 246D6BA3   |
    And joe.black@example.com has the following devices:
      | Phone      | 5125551236 |
    And henry.frank@example.com  has the following devices:
      | SMS        | 5125551247 |
    And martin.gons@example.com  has the following devices:
      | Blackberry | 246D6BA6 |
    And george.strait@example.com  has the following devices:
      | Phone | 5125551239 |
      | Blackberry | 246D6BA7 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to users with multiple devices
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com, joe.black@example.com, henry.frank@example.com, martin.gons@example.com, george.strait@example.com |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | None                                 |
      | communication_methods | Phone, SMS, Blackberry               |
      | caller_id             | 0987654321                           |

    Then the following phone calls should be made:
      | phone      | message                                                                                                      |
      | 5125551235 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |
      | 5125551236 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |
      | 5125551239 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |

    Then the following SMS calls should be made:
      | sms           | message                            |
      | 15125551245   | Chicken pox outbreak short message |
      | 15125551247   | Chicken pox outbreak short message |

    And the following Blackberry calls should be made:
      | blackberry    | message                            |
      | 246D6BA3      | Chicken pox outbreak short message |
      | 246D6BA6      | Chicken pox outbreak short message |
      | 246D6BA7      | Chicken pox outbreak short message |

    And the following users should receive the alert email:
      | People        |  anne.smith@example.com, joe.black@example.com, henry.frank@example.com, martin.gons@example.com, george.strait@example.com |
      | body contains | Title: There is a Chicken pox outbreak                                                                                      |
