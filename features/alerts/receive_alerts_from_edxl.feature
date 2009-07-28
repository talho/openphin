Feature: Alerts from EDXL

  Background:
    Given the following entities exists:
      | role | Health Officer |
      | role | Emergency Preparedness Coordinator |
      | role | Chief Epidemiologist |
      | role | Communicable/Infectious Disease Coordinators |
      | role | HAN Coordinator  |
      | organization | CDC                   |
      | jurisdiction | Texas                 |
      | jurisdiction | Potter County         |
      | user | John Smith |
    And "CDC" has the OID "2.16.840.1.114222.4.20.1.1"
    And "Texas" has the FIPS code "01091"
    And "Potter County" has the FIPS code "01003"

  Scenario: Receiving an alert through EDXL
    When PhinMS delivers the message: PCAMessageAlert.xml
    Then an alert exists with:
      | identifier | CDC-2006-183 |
      | from_organization | CDC |
      | from_organization_name | Centers for Disease Control and Prevention |
      | from_organization_oid  | 2.16.840.1.114222.4.20.1.1 |
      | sent_at | 2006-11-07T21:25:16.5127Z |
      | status  | Test |
      | message_type | Alert |
      | scope | Restricted |
      | category | Health |
      | program | HAN |
      | urgency | Expected |
      | severity | Severe |
      | certainty | Very Likely |
      | title | Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees |
      | message | To date, seven people in the area effected by Hurricane Katrina have been reported ill from the bacterial disease Vibrio vulnificus. |
      | acknowledge | Yes |
      | delivery_time | 1440 |
      | jurisdictional_level | StateLocal |
      | program_type | Notification |
      | jurisdiction | Texas |
      | jurisdiction | Potter County |
      | role | Health Officer |
      | role | Emergency Preparedness Coordinator |
      | role | Chief Epidemiologist |
      | role | Communicable/Infectious Disease Coordinators |
      | role | HAN Coordinator  |
  
  Scenario: Receiving an EDXL alert update
    When PhinMS delivers the message: PCAMessageUpdate.xml
    Then an alert exists with:
      | identifier | CDC-2006-183 |
      | references | 2.16.840.1.114222.4.20.1.1,CDC-2006-182,2006-11-05T13:02:42.1219Z |
      | message_type | Update |
  
  Scenario: Receiving an EDXL alert cancel
    When PhinMS delivers the message: PCAMessageCancel.xml
    Then an alert exists with:
      | identifier | CDC-2006-183 |
      | references | 2.16.840.1.114222.4.20.1.1,CDC-2006-182,2006-11-05T13:02:42.1219Z |
      | message_type | Cancel |

  Scenario: Receiving an EDXL Acknowledgment
    Given "Red Cross" has the OID "2.16.840.7.1234567.5.82.2.1"
    And Red Cross is a foreign Organization
    And a sent alert with:
      | identifier | CDC-2006-183 |
      | organizations | Red Cross |
      | jurisdictions | Federal |
      | author        | John Smith |
	When PhinMS delivers the message: PCAAckExample.xml
    Then the alert "CDC-2006-183" should be acknowledged
    

