Feature: Alerts from EDXL


  Scenario: Receiving an EDXL Acknowledgment

  Scenario: Receiving an alert through EDXL
    Given an organization named "CDC"
    And "CDC" has the OID "2.16.840.1.114222.4.20.1.1"
    And a jurisdiction named "Texas"
    And "Texas" has the FIPS code "01091"
    And a jurisdiction named "Potter County"
    And "Potter County" has the FIPS code "01003"
    When PhinMS delivers the message: PCAMessageAlert.xml
    Then I see an alert with:
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
      # | role | Health Officer |
      # | role | Emergency Preparedness Coordinator |
      # | role | Chief Epidemiologist |
      # | role | Communicable/Infectious Disease Coordinators |
      # | role | HAN Coordinator  |
      # | jurisdiction | Texas |
      # | jurisdiction | Potter County |
  
  Scenario: Recieving an EDXL alert update
  
  Scenario: Recieving an EDXL alert cancel
