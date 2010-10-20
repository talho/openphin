Feature: Sending alerts to BlackBerry devices

  In order to be notified of an alert
  As a user
  I want people to be able to send me alerts on my BlackBerry device

  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Dallas County  |
    And "john.smith@example.com" has the following devices:
      | blackberry | 1234567890 |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And delayed jobs are processed

  Scenario: Sending alerts to Blackberry devices
    Given a sent alert with:
      | type                  | MACC                                 |
      | author                | john.smith@example.com               |
      | from_jurisdiction     | Dallas County                        |
      | people                | john.smith@example.com               |
      | title                 | Flying Monkey Disease                |
      | message               | For more details, keep on reading... |
      | short_message         | Flying Monkey Disease short message  |
      | acknowledge           | None                                 |
      | communication_methods | E-mail, Blackberry                   |
      | caller_id             | 0987654321                           |
    Then the following Blackberry calls should be made:
      | blackberry | message                             |
      | 1234567890 | Flying Monkey Disease short message |