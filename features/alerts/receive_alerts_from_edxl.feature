Feature: Alerts from EDXL

  Background:
    Given the following entities exists:
      | role | Health Officer |
      | role | Emergency Preparedness Coordinator |
      | role | Chief Epidemiologist |
      | role | Communicable/Infectious Disease Coordinators |
      | role | Health Alert and Communications Coordinator |
      | role | HAN Coordinator  |
      | organization | CDC                   |
      | jurisdiction | Federal               |
      | jurisdiction | Texas                 |
      | jurisdiction | Potter County         |
      | jurisdiction | Wise County           |
      | jurisdiction | Louisiana             |
      | jurisdiction | Calcasieu             |
      | user | John Smith |
    And "CDC" has the OID "2.16.840.1.114222.4.20.1.1"
    And "Texas" has the FIPS code "48"
    And "Potter County" has the FIPS code "01003"
    And "Wise County" has the FIPS code "01091"
    And "Calcasieu" has the FIPS code "22019"
    And Federal is a foreign jurisdiction
    And Federal is the parent jurisdiction of:
      | Texas | Louisiana |
    And Texas is the parent jurisdiction of:
      | Potter County | Wise County |
    And Louisiana is the parent jurisdiction of:
      | Calcasieu |
    And the following users exist:
    | Keith Gaddis | keith@example.com  | Health Alert and Communications Coordinator | Texas |
    | Bob Dole     | bob@example.com  | Health Alert and Communications Coordinator | Potter County |
    | Jason Phipps | jphipps@example.com | Chief Epidemiologist | Potter County |
    | Wise Coordinator | wisecoordinator@example.com | Health Alert and Communications Coordinator | Wise County |
    | Daniel Morrison | daniel@example.com | Health Officer | Wise County |
    | Brandon Keeper | brandon@example.com | Health Officer | Texas |
    | Zach Dennis | zach@example.com | Health Officer | Texas |
    | Mark Jensen | mjensen@cdc.gov  | Public | Texas |
    | Ethan Waldo | ethan@example.com | Public | Potter County |

  Scenario: Receiving an alert through EDXL
    When PhinMS delivers the message: PCAMessageAlert.xml
    Then an alert exists with:
      | identifier | CDC-2009-183 |
      | from_organization | CDC |
      | from_organization_name | Centers for Disease Control and Prevention |
      | from_organization_oid  | 2.16.840.1.114222.4.20.1.1 |
      | sent_at | 2009-11-07T21:25:16.5127Z |
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
      | program_type | Notification |
      | jurisdiction | Potter County |
      | role | Health Officer |
      | role | Emergency Preparedness Coordinator |
      | role | Chief Epidemiologist |
      | role | Communicable/Infectious Disease Coordinators |
    And the following users should receive the email:
      | People        | keith@example.com, bob@example.com, daniel@example.com, jphipps@example.com, zach@example.com |
      | subject       | Severe Health Alert Test Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees |
      | body contains | To date, seven people in the area effected by Hurricane Katrina have been reported ill from the bacterial disease Vibrio vulnificus. |
    And "ethan@example.com" should not receive an email with the subject "Severe Health Alert Test Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees"
    And "brandon@example.com" should not receive an email with the subject "Severe Health Alert Test Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees"
    And "mjensen@cdc.gov" should not receive an email with the subject "Severe Health Alert Test Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees"

   Scenario: Receiving an alert with enumerated users and roles through PhinMS
    When PhinMS delivers the message: test-CDC-cascade.edxl
    Then an alert exists with:
      | identifier | CDC-2009-66 |
      | from_organization_name | Centers for Disease Control |
      | from_organization_oid  | 2.16.840.1.114222.4.1.3683 |
      | sent_at | 2009-08-27 10:55:44 -0500 |
      | status  | Test |
      | message_type | Alert |
      | program | HAN |
      | urgency | Unknown |
      | severity | Minor |
      | certainty | Likely |
      | title | Cascade alert sent from Federal jurisdiction to TX |
      | message | Message Body Message Body Message Body Message Body Message Body Message Body |
      | acknowledge | No |
      | delivery_time | 60 |
      | program_type | Alert |
      | jurisdiction | Texas |
      | role | Health Alert and Communications Coordinator |
    And the following users should receive the email:
     | People        | mjensen@cdc.gov,keith@example.com |
     | subject       | Cascade alert sent from Federal jurisdiction to TX    |
     | body contains | Message Body Message Body Message Body Message Body Message Body Message Body |
    And "ethan@example.com" should not receive an email with the subject "Cascade alert sent from Federal jurisdiction to TX"
    When I log in as "mjensen@cdc.gov"
    And I go to the alerts page
    Then I should see 1 alerts

  
  Scenario: Receiving an EDXL alert udpate
    When PhinMS delivers the message: PCAMessageAlert.xml
    Then an alert exists with:
      | identifier | CDC-2009-183 |
      | message_type | Alert |
    When I log in as "keith@example.com"
    And I go to the alerts page
    Then I should see 1 alerts     
    When PhinMS delivers the message: PCAMessageUpdate.xml
    Then an alert exists with:
      | identifier | CDC-2009-184 |
      | references | 2.16.840.1.114222.4.20.1.1,CDC-2009-183,2009-11-05T13:02:42.1219Z |
      | message_type | Update |
    And the cancelled alert "CDC-2009-184" has an original alert "CDC-2009-183"
    And the following users should receive the email:
      | People        | keith@example.com |
      | subject       | Severe Health Alert Test [Update] - Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees |
      | body contains | To date, seven people in the area effected by Hurricane Katrina have been reported ill from the bacterial disease Vibrio vulnificus. |
    When I log in as "keith@example.com"
    And I go to the alerts page
    Then I should see 2 alerts     
  
  Scenario: Receiving an EDXL alert cancel
    When PhinMS delivers the message: PCAMessageAlert.xml
    Then an alert exists with:
      | identifier | CDC-2009-183 |
      | message_type | Alert |
    When I log in as "keith@example.com"
    And I go to the alerts page
    Then I should see 1 alerts     
    When PhinMS delivers the message: PCAMessageCancel.xml
    Then an alert exists with:
      | identifier | CDC-2009-185 |
      | references | 2.16.840.1.114222.4.20.1.1,CDC-2009-183,2009-11-05T13:02:42.1219Z |
      | message_type | Cancel |
    And the cancelled alert "CDC-2009-185" has an original alert "CDC-2009-183"
    And the following users should receive the email:
      | People        | keith@example.com |
      | subject       | Severe Health Alert Test [Cancel] - Cases of Vibrio vulnificus identified among Hurrican Katrina evacuees |
      | body contains | To date, seven people in the area effected by Hurricane Katrina have been reported ill from the bacterial disease Vibrio vulnificus. |
    When I log in as "keith@example.com"
    And I go to the alerts page
    Then I should see 2 alerts     

  Scenario: Receiving an EDXL Acknowledgment that was originally sent via an organization
    Given this is implemented
    And "Red Cross" has the OID "2.16.840.7.1234567.5.82.2.1"
    And Red Cross is a foreign Organization
    And a sent alert with:
      | identifier | CDC-2006-183 |
      | organizations | Red Cross |
      | jurisdictions | Federal |
      | author        | John Smith |
	When PhinMS delivers the message: PCAAckExample.xml
    Then the alert "CDC-2006-183" should be acknowledged
    
  Scenario: Receiving an EDXL Acknowledgment that was originally sent via the federal jurisdiction
    Given a sent alert with:
      | identifier | DSHS-2009-183 |
      | jurisdictions | Federal |
      | author        | John Smith |
	When PhinMS delivers the message: PCAAckExample.xml
    Then the alert "DSHS-2009-183" should be acknowledged
    
  Scenario: Receiving an EDXL Acknowledgment that was originally sent via a non-federal jurisdiction
    Given Calcasieu is a foreign jurisdiction
    And a sent alert with:
      | identifier | DSHS-2009-183 |
      | jurisdictions | Calcasieu |
      | author        | John Smith |
	When PhinMS delivers the message: PCAAckExample.xml
    Then the alert "DSHS-2009-183" should be acknowledged