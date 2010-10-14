Feature: Fetching acknowledgement data from XML and using the remote timestamp for acknowledgement_at
  In order to have more precise acknowledgement timestamps
  As an admin
  I should see the SWN-provided timestamp for acknowledged alerts in the Alert Log.

  Background:
    Given the following entities exists:
      | Jurisdiction  | Bell County                                 |
      | Role          | Health Alert and Communications Coordinator |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And the following users exist:
      | John Smith    | john.smith@example.com | Health Alert and Communications Coordinator | Bell County |


  Scenario: Fetch XML and parse acknowledgements using SWN's timestamp, Normal acknowledgement
    Given a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | Yes                     |
      | from_jurisdiction     | Bell County             |
      | communication methods | Email                   |
      | people                | John Smith              |
    And the backgroundRB worker has queried and processed the SWN XML data "features/fixtures/SWN_normal_response.xml"
    Then the alert should be acknowledged at time "2010-10-08 15:06:19"

  Scenario: Fetch XML and parse acknowledgements using SWN's timestamp, Advanced acknowledgement
    Given a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | Yes                     |
      | from_jurisdiction     | Bell County             |
      | communication methods | Email                   |
      | alert_response_1      | response one            |
      | alert_response_2      | Response the second     |
      | alert_response_3      | this is Response three  |
      | alert_response_4      | Fourth response         |
      | people                | John Smith              |
    And the backgroundRB worker has queried and processed the SWN XML data "features/fixtures/SWN_advanced_response.xml"
    Then the alert should be acknowledged at time "2010-10-12 09:35:46"
    And the alert should be acknowledged with response number "3"

  Scenario: SWN XML can acknowledge after an alert expires but within the 4-hour grace period
    Given a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | Yes                     |
      | from_jurisdiction     | Bell County             |
      | communication methods | Email                   |
      | people                | John Smith              |
      | delivery time         | 24 hours                |
    And 26 hours pass
    And the backgroundRB worker has queried and processed the SWN XML data "features/fixtures/SWN_normal_response.xml"
    Then the latest alert should be acknowledged    

  Scenario: SWN XML can't acknowledge after an alert expires
    Given a sent alert with:
      | title                 | TEST ALERT              |
      | message               | TEST PLEASE DISREGARD   |
      | acknowledge           | Yes                     |
      | from_jurisdiction     | Bell County             |
      | communication methods | Email                   |
      | people                | John Smith              |
      | delivery time         | 24 hours                |
    And 30 hours pass
    And the backgroundRB worker has queried and processed the SWN XML data "features/fixtures/SWN_normal_response.xml"
    Then the alert should not be acknowledged