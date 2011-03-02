@ext
Feature: Creating and sending alerts

  In order to notify others in a timely fashion
  As a user
  I can create and send alerts

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County                               |
      | Jurisdiction | Tarrant County                              |
      | Jurisdiction | Wise County                                 |
      | Jurisdiction | Potter County                               |
      | Jurisdiction | Texas                                       |
      | Role         | Health Alert and Communications Coordinator |
      | Role         | Health Officer                              |
      | Role         | Immunization Director                       |
      | Role         | Epidemiologist                              |
      | Role         | WMD Coordinator                             |
    And the following users exist:
      | John Smith      | john.smith@example.com     | Health Alert and Communications Coordinator  | Dallas County  |
      | Brian Simms     | brian.simms@example.com    | Epidemiologist                               | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com    | Public                                       | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com    | Health Officer                               | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com   | Epidemiologist                               | Wise County    |
      | Jason Phipps    | jason.phipps@example.com   | WMD Coordinator                              | Potter County  |
      | Dan Morrison    | dan.morrison@example.com   | Health Officer                               | Ottawa County  |
      | Brian Ryckbost  | brian.ryckbost@example.com | Health Officer                               | Tarrant County |
    And delayed jobs are processed
    And "john.smith@example.com" is not public in "Texas"
    And "brian.simms@example.com" is not public in "Texas"
    And "ed.mcguyver@example.com" is not public in "Texas"
    And "ethan.waldo@example.com" is not public in "Texas"
    And "keith.gaddis@example.com" is not public in "Texas"
    And "jason.phipps@example.com" is not public in "Texas"
    And "dan.morrison@example.com" is not public in "Texas"
    And "brian.ryckbost@example.com" is not public in "Texas"

    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |

    And the role "Health Alert and Communications Coordinator" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    When I navigate to the ext dashboard page
    And I navigate to "HAN > Send an Alert"

  Scenario: Sending an alert directly to a user
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."
    And I select "15 minutes" from ext combo "Delivery Time"

    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People        | keith.gaddis@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    #TODO: To be implemented
    #And "fix the above step to include an alert id" should be implemented

  Scenario: Previewing an alert                              
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."

    And I select the following alert audience:
      | name            | type         |
      | Dallas County   | Jurisdiction |
      | Potter County   | Jurisdiction |
      | Health Officer  | Role         |
      | Epidemiologist  | Role         |
      | Keith Gaddis    | User         |
    And I click breadCrumbItem "Preview"

    And I should see "For more details, keep on reading..."
    And I should see "H1N1 SNS push packs to be delivered tomorrow"
    And I should see a display form with:
      | Severity      | Moderate |
      | Status        | Actual   |
      | Acknowledge   | No       |
      | Methods       | Email    |
      | Delivery Time | 72 hours |

    And I expand ext panel "Alert Recipients (Primary Audience)"
    And I should see the following audience breakdown
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Potter County  | Jurisdiction |
      | Health Officer | Role         |
      | Epidemiologist | Role         |
      | Keith Gaddis   | User         |

    When I click breadCrumbItem "Alert Details"
    And I fill in "Title" with "Something Different"
    And I click breadCrumbItem "Preview"
    And I should see "For more details, keep on reading..."
    And I should see "Something Different"
    And I should see a display form with:
      | Severity      | Moderate |
      | Status        | Actual   |
      | Acknowledge   | No       |
      | Methods       | Email    |
      | Delivery Time | 72 hours |
    And I should see the following audience breakdown
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Potter County  | Jurisdiction |
      | Health Officer | Role         |
      | Epidemiologist | Role         |
      | Keith Gaddis   | User         |

  Scenario: Sending an alert to specific users sends alerts to each user
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."

    And I select the following alert audience:
      | name         | type |
      | Keith Gaddis | User |
      | Dan Morrison | User |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People       | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    #TODO: To be implemented
    #And "fix the above step to include an alert id" should be implemented

  Scenario: Sending an alert with specified Jurisdictions sends to all users within those Jurisdictions
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."

    And I select the following alert audience:
      | name          | type         |
      | Dallas County | Jurisdiction |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People        | john.smith@example.com, brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    #TODO: To be implemented
    #And "fix the above step to include an alert id" should be implemented

  Scenario: Sending an alert with specified Jurisdictions/Roles scopes who the alerts are sent to
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."

    And I select the following alert audience:
      | name           | type         |
      | Dallas County  | Jurisdiction |
      | Tarrant County | Jurisdiction |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People        | john.smith@example.com, ethan.waldo@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    #TODO: To be implemented
    #And "fix the above step to include an alert id" should be implemented

  Scenario: Sending an alert with specified Roles scopes who the alerts are sent to
    When I fill in the ext alert defaults
    And I select "Moderate" from ext combo "Severity"
    And I fill in "Message" with "For more details, keep on reading..."

    And I select the following alert audience:
      | name           | type |
      | Health Officer | Role |

    And I click breadCrumbItem "Preview"
    And I wait for the audience calculation to finish
    And I press "Send Alert"
    Then the "Alert Log and Reporting" tab should be open

    And the following users should receive the alert email:
      | People        | ethan.waldo@example.com, dan.morrison@example.com, brian.ryckbost@example.com |
      | subject       | Health Alert "H1N1 SNS push packs to be delivered tomorrow" |
      | body contains | Title: H1N1 SNS push packs to be delivered tomorrow |
      | body contains | Alert ID:  |
      | body contains | Agency: Dallas County |
      | body contains | Sender: John Smith |
      | body contains | For more details, keep on reading... |
    #TODO: To be implemented
    #And "fix the above step to include an alert id" should be implemented