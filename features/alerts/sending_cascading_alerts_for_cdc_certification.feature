Feature: Sending CDC test cases
  In order to pass CDC certification and have the world beat a path to our door
  As an alerter
  I want to use OpenPHIN to send cascade alerts according to the test case specifications

  Background:
    Given the following entities exists:
      | Jurisdiction | Louisiana                                |
      | Jurisdiction | Cameron Parish                           |
      | Jurisdiction | Calcasieu Parish                         |
      | Jurisdiction | Beauregard Parish                        |
      | Jurisdiction | Federal                                  |
      | Jurisdiction | Texas                                    |
      | Role         | Chief Epidemiologist                     |
      | Role         | Bioterrorism Coordinator                 |
      | Role         | Emergency Management Coordinator         |
    And the following FIPS codes exist:
      | Louisiana          | 30    |
      | Cameron Parish    | 30001 |
      | Calcasieu Parish  | 30002 |
      | Beauregard Parish | 30003 |
      | Texas             | 48    |
    And Federal is a foreign jurisdiction
    And Louisiana is a foreign jurisdiction
    And Cameron Parish is a foreign jurisdiction
    And Calcasieu Parish is a foreign jurisdiction
    And Beauregard Parish is a foreign jurisdiction
    And Federal is the parent jurisdiction of:
      | Texas    |
      | Louisiana |
    And Louisiana is the parent jurisdiction of:
      | Cameron Parish    |
      | Calcasieu Parish  |
      | Beauregard Parish |
    And the following users exist:
      | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator  | Texas     |
      | Mark Jensen     | mjensen@cdc.gov          | Public          | Louisiana |
      | TLP7 CDC        | tlp7@cdc.gov             | Public          | Louisiana |
    And delayed jobs are processed
    And the role "Health Alert and Communications Coordinator" is an alerter

    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I go to the HAN
    And I follow "Send an Alert"

  Scenario: Trying to send cascading alert that should not cascade
    When I fill out the alert form with:
      | Title                 | H1N1 SNS push packs to be delivered tomorrow |
      | Message               | For more details, keep on reading...         |
      | Acknowledge           | None                                         |
    And I check "E-mail"
    And I press "Select an Audience"
    And delayed jobs are processed
    And I fill out the alert "Audience" form with:
      | Jurisdictions         | Texas                                        |
      | Role                  | Bioterrorism Coordinator                     |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send this Alert"
    Then I should see "Successfully sent the alert"
    And no foreign alert "H1N1 SNS push packs to be delivered tomorrow" is sent

  Scenario: Test case 1--Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)
    When I fill out the alert form with:
      | Jurisdictions         | Cameron Parish,Calcasieu Parish,Beauregard Parish                       |
      | Role                  | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | Title                 | Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB) |
      | Message               | The Texas Department of State Health Services is workign with the CDC and local health officials and other partners on an investigation involving an international traveler to the U.S. who had recently been diagnosed with multidrug-resistant tuberculosis (MDR TB).  A local health authority reported that a patient who had been diagnosed in India with MDR TB traveled in December from New Delhi, India to Chicago, Illinois and then on a shorter flight to Austin. |
      | Acknowledge           | None                         |
      | Sensitive             | <unchecked>                  |
      | Severity              | Moderate                     |
      | Delivery Time         | 72 hours                     |
      | People                | Mark Jensen,TLP7 CDC         |
      | Communication methods | E-mail                       |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"    
    # Title is truncated to 46 characters
    And a foreign alert "Investigation of International Traveler with M" is sent

  Scenario: Test case 2--Multiple States Investigating a Large Outbreak of E. coli O157:H7 Infections
    When I fill out the alert form with:
      | Jurisdictions         | Federal               |
      | Role                  | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | Title                 | Multiple States Investigating a Large Outbreak of E. coli O157:H7 Infections      |
      | Message               | Public health officials in multiple states, with the assistance of the CDC, are investigating a large outbreak of E. coli O157:H7 infections. Thus far, 50 cases have been reported in 17 states, including 3 adjacent states. The outbreak is likely ongoing. |
      | Acknowledge           | None                  |
      | Sensitive             | <unchecked>           |
      | Severity              | Severe                |
      | Delivery Time         | 24 hours              |
      | People                | Mark Jensen,TLP7 CDC  |
      | Communication methods | E-mail                |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "Multiple States Investigating a Large Outbreak" is sent

  Scenario: Test case 3--Possible Ricin exposures detected
    When I fill out the alert form with:
      | Jurisdictions         | Federal               |
      | Role                  | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | Title                 | Possible Ricin exposures detected |
      | Message               | The Texas Department of State Health Services is working collaboratively with the CDC, the FBI, and other public health and law enforcement agencies to investigate a case of possible ricin exposure. Preliminary results of environmental testing have tested positive for ricin |
      | Acknowledge           | None                  |
      | Sensitive             | <checked>             |
      | Severity              | Extreme               |
      | Delivery Time         | 24 hours              |
      | People                | Mark Jensen,TLP7 CDC  |
      | Communication methods | E-mail                |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "Possible Ricin exposures detected" is sent

  Scenario: Test case 4--Test of the Alerting Network
    When I fill out the alert form with:
      | Jurisdictions         | Federal               |
      | Role                  | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | Title                 | Test of the Alerting Network |
      | Message               | This is a test of the Texas Department of State Health Services alerting network. This test is performed quarterly to measure the effectiveness of alerts reaching the intended recipients. Follow the defined steps to acknowledge receipt of this test alert |
      | Acknowledge           | Normal                |
      | Sensitive             | <unchecked>           |
      | Severity              | Moderate              |
      | Delivery Time         | 24 hours              |
      | People                | Mark Jensen,TLP7 CDC  |
      | Communication methods | E-mail                |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "Test of the Alerting Network" is sent

  Scenario: Test case 5--Update: Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)
    Given a sent alert with:
      | jurisdictions         | Cameron Parish,Calcasieu Parish,Beauregard Parish                       |
      | roles                 | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | title                 | Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB) |
      | message               | The Centers for Disease Control and Prevention (CDC) and state health officials in 17 states based located and tested 42 of the 44 potentially exposed pssengers. All of the exposed passengers tested had negative TST results. |
      | acknowledge           | None                         |
      | sensitive             | <unchecked>                  |
      | severity              | Moderate                     |
      | delivery time         | 72 hours                     |
      | people                | Mark Jensen,TLP7 CDC         |
      | communication methods | Email                        |
      | from_jurisdiction     | Texas                        |
    
    When I load the update alert page for "Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)"
    When I fill out the alert form with:
      | Message               | The Centers for Disease Control and Prevention (CDC) and state health officials in 17 states based located and tested 42 of the 44 potentially exposed passengers. All of the exposed passengers tested had negative TST results. |
      | Acknowledge           | None                  |
      | Sensitive             | <unchecked>           |
      | Severity              | Minor                 |
      | Delivery Time         | 24 hours              |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "[Update] - Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)" is sent
    When I log in as "mjensen@cdc.gov"
    And I go to the HAN
    Then I should see 2 alerts

  Scenario: Test case 6--Cancel: Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)
    Given a sent alert with:
      | jurisdictions         | Cameron Parish,Calcasieu Parish,Beauregard Parish                       |
      | roles                 | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
      | title                 | Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB) |
      | message               | The Texas Department of State Health Services is working with the CDC and local health officials and other partners on an investigation involving an international traveler to the U.S. who had recently been diagnosed with multidrug-resistant tuberculosis (MDR TB).  A local health authority reported that a patient who had been diagnosed in India with MDR TB traveled in December from New Delhi, India to Chicago, Illinois and then on a shorter flight to Austin. |
      | acknowledge           | None                         |
      | sensitive             | <unchecked>                  |
      | severity              | Moderate                     |
      | delivery time         | 72 hours                     |
      | people                | Mark Jensen,TLP7 CDC         |
      | communication methods | Email                        |
      | from_jurisdiction     | Texas                        |
    When I load the cancel alert page for "Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)"
    When I fill out the alert form with:
      | Message               | This alert has been cancelled.  |
      | Acknowledge           | None                  |
      | Sensitive             | <unchecked>           |
      | Severity              | Minor                 |
      | Delivery Time         | 24 hours              |
    And I press "Preview Message"
    Then I should see a preview of the message

    When I press "Send"
    Then I should see "Successfully sent the alert"
    And a foreign alert "[Cancel] - Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)" is sent
    When I log in as "mjensen@cdc.gov"
    And I go to the HAN
    Then I should see 2 alerts
