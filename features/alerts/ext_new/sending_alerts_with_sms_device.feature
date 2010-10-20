@ext
Feature: Sending alerts to SMS devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my SMS device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
      | Anne Smith      | anne.smith@example.com   | Epidemiologist                              | Wise County    |
    And "anne.smith@example.com" has the following devices:
      | sms | 1234567890 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to SMS devices
    Given a sent alert with:
      | type                  | HAN                                  |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | anne.smith@example.com               |
      | title                 | Chicken pox outbreak                 |
      | message               | There is a Chicken pox outbreak.     |
      | short_message         | Chicken pox outbreak short message   |
      | acknowledge           | None                                 |
      | communication_methods | SMS                                  |
      | caller_id             | 0987654321                           |
    Then the following SMS calls should be made:
      | sms         | message                            |
      | 1234567890 | Chicken pox outbreak short message |