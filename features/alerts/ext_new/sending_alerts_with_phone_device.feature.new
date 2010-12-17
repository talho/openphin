@ext
Feature: Sending alerts to phones

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my phone

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Wise County    |
      | Anne Smith      | anne.smith@example.com   | Epidemiologist                               | Wise County    |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And "anne.smith@example.com" has the following devices:
      | phone | 1234567890 |
      | phone | 5556667777 |
    And delayed jobs are processed

  Scenario: Sending alerts to phone devices
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com               |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | None                                 |
      | communication_methods | Phone                                |
      | caller_id             | 0987654321                           |
    Then the following phone calls should be made:
      | phone      | message                                                                                                      |
      | 1234567890 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |

  Scenario: Sending alerts to phone devices with acknowledgment
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com               |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | Normal                               |
      | communication_methods | Phone                                |
      | caller_id             | 0987654321                           |
    Then the following phone calls should be made:
      | phone      | message                                                                                                      |
      | 1234567890 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |
    And "anne.smith@example.com" has not acknowledged the alert "Chicken pox outbreak"

  Scenario: Sending alerts to users with multiple phone devices
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com               |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | Normal                               |
      | communication_methods | Phone                                |
      | caller_id             | 0987654321                           |
    Then the following phone calls should be made:
      | phone      | message       |
      | 1234567890 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |
      | 5556667777 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak |

  Scenario: Sending alerts with call down
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com               |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | Normal                               |
      | communication_methods | Phone                                |
      | caller_id             | 0987654321                           |
      | Alert Response 1      | if you can respond within 15 minutes |
      | Alert Response 2      | if you can respond within 30 minutes |
      | Alert Response 3      | if you can respond within 1 hour     |
      | Alert Response 4      | if you can respond within 4 hours    |
      | Alert Response 5      | if you cannot respond                |     
    Then the following phone calls should be made:
      | phone      | message                                                                                                      | call_down                            |
      | 1234567890 | The following is an alert from the Texas Public Health Information Network.  There is a Chicken pox outbreak | if you can respond within 15 minutes |
    And the phone call should have 5 calldowns