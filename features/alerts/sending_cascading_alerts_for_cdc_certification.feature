Feature: Sending CDC test cases
  In order to pass CDC certification and have the world beat a path to our door
  As an alerter
  I want to use OpenPHIN to send cascade alerts according to the test case specifications

  Background:
    Given the following entities exists:
          | Jurisdiction | Lousiana                                 |
          | Jurisdiction | Cameron Parish                           |
          | Jurisdiction | Calcasieu Parish                         |
          | Jurisdiction | Beauregard Parish                        |
          | Jurisdiction | Federal                                  |
          | Jurisdiction | Texas                                    |
          | Role         | Chief Epidemiologist                     |
          | Role         | Bioterrorism Coordinator                 |
          | Role         | Emergency Management Coordinator         |
        And the following FIPS codes exist:
          | Lousiana          | 30    |
          | Cameron Parish    | 30001 |
          | Calcasieu Parish  | 30002 |
          | Beauregard Parish | 30003 |
          | Texas             | 48    |
        And Federal is a foreign jurisdiction
        And Lousiana is a foreign jurisdiction
        And Cameron Parish is a foreign jurisdiction
        And Calcasieu Parish is a foreign jurisdiction
        And Beauregard Parish is a foreign jurisdiction
        And Federal is the parent jurisdiction of:
          | Texas    |
          | Lousiana |
        And Lousiana is the parent jurisdiction of:
          | Cameron Parish    |
          | Calcasieu Parish  |
          | Beauregard Parish |
        And the following users exist:
          | John Smith      | john.smith@example.com   | Health Officer  | Texas    |
          | Mark Jensen     | mjensen@cdc.gov          | Public          | Lousiana |
          | TLP7 CDC        | tlp7@cdc.gov             | Public          | Lousiana |


        And the role "Health Officer" is an alerter
        And I am logged in as "john.smith@example.com"
        And I am allowed to send alerts
        When I go to the dashboard page
        And I follow "Send an Alert"

  Scenario: Trying to send cascading alert that should not cascade
     When I fill out the alert form with:
       | Jurisdictions | Texas                                   |
       | Role         | Bioterrorism Coordinator                    |
       | Title    | H1N1 SNS push packs to be delivered tomorrow |
       | Message  | For more details, keep on reading...         |
       | Acknowledge | <unchecked>                               |
       | Communication methods | E-mail                          |

     And I press "Preview Message"
     Then I should see a preview of the message

     When I press "Send"
     Then I should see "Successfully sent the alert"
     And no foreign alert "H1N1 SNS push packs to be delivered tomorrow" is sent

  Scenario: Test case 1--Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)
    When I fill out the alert form with:
          | Jurisdictions         | Cameron Parish,Calcasieu Parish,Beauregard Parish                       |
          | Role                  | Chief Epidemiologist, Bioterrorism Coordinator,Emergency Management Coordinator   |
          | Title                 | Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB) |
          | Message               | The Texas Department of State Health Services is workign with the CDC and local health officials and other partners on an investigation involving an international traveler to the U.S. who had recently been diagnosed with multidrug-resistant tuberculosis (MDR TB).  A local health authority reported that a patient who had been diagnosed in India with MDR TB traveled in December from New Delhi, India to Chicago, Illinois and then on a shorter flight to Austin. |
          | Acknowledge           | <unchecked>                                                                       |
          | Sensitive             | <unchecked>                                                                       |
          | Severity              | Moderate                                                                          |
          | Delivery Time         | 72 hours                                                                          |
          | People                | Mark Jensen,TLP7 CDC                                                      |
          | Communication methods | E-mail                                                                            |
        And I press "Preview Message"
        Then I should see a preview of the message

        When I press "Send"
        Then I should see "Successfully sent the alert"
        And a foreign alert "Investigation of International Traveler with Multidrug-Resistant Tuberculosis (MDR TB)" is sent