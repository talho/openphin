Feature: Sending documents with selected scopes

  In order to send documents to groups of users
  As a user
  I can send documents

  Background:
    Given the following entities exists:
      | Jurisdiction  | Dallas County         |
      | Jurisdiction  | Tarrant County        |
      | Jurisdiction  | Wise County           |
      | Jurisdiction  | Potter County         |
      | Jurisdiction  | Texas                 |
      | Approval Role | Health Officer        |
      | Approval Role | Immunization Director |
      | Approval Role | Epidemiologist        |
      | Approval Role | WMD Coordinator       |
    And the following users exist:
      | John Smith      | john.smith@example.com      | Health Officer  | Dallas County  |
      | Brian Simms     | brian.simms@example.com     | Epidemiologist  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com     | Public          | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com     | Health Officer  | Tarrant County |
      | Brandon Keepers | brandon.keepers@example.com | Epidemiologist  | Wise County    |
      | Jason Phipps    | jason.phipps@example.com    | WMD Coordinator | Potter County  |
      | Dan Morrison    | dan.morrison@example.com    | Health Officer  | Ottawa County  |
      | Brian Ryckbost  | brian.ryckbost@example.com  | Health Officer  | Tarrant County |
    And "john.smith@example.com" is not public in "Texas"
    And "brian.simms@example.com" is not public in "Texas"
    And "ed.mcguyver@example.com" is not public in "Texas"
    And "ethan.waldo@example.com" is not public in "Texas"
    And "brandon.keepers@example.com" is not public in "Texas"
    And "jason.phipps@example.com" is not public in "Texas"
    And "dan.morrison@example.com" is not public in "Texas"
    And "brian.ryckbost@example.com" is not public in "Texas"

    And Texas is the parent jurisdiction of:
      | Dallas County | Tarrant County | Wise County | Potter County |

    And the role "Health Officer" is an alerter
    When delayed jobs are processed
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "sample.wav"
    And I select "#send" from the documents toolbar
    Then I wait for the "div#send_document_panel div#edit" element to load

  Scenario: Sending a document directly to a user
    When I fill out the document sharing form with:
    | People | Brandon Keepers |

    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    And "brandon.keepers@example.com" should receive the email:
      | subject       | John Smith shared a document with you |
      | body contains | To view this document                 |

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sending a document with multiple users
    When I fill out the document sharing form with:
      | People | Dan Morrison, Brandon Keepers, Ed McGuyver |

    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"

    And the following users should receive the email:
      | People        | brandon.keepers@example.com, dan.morrison@example.com |
      | subject       | John Smith sent a document to you                     |
      | body contains | To view this document                                 |
    And "ed.mcguyver@example.com" should not receive an email

    Given I am logged in as "brandon.keepers@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

    Given I am logged in as "dan.morrison@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sending a document with specified Jurisdictions copies it to all users within those Jurisdictions
    When I fill out the document sending form with:
      | Jurisdictions | Dallas County |

    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com |
      | subject       | John Smith sent a document to you               |
      | body contains | To view this document                           |
    And "ed.mcguyver@example.com" should not receive an email
    And "ethan.waldo@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

    Given I am logged in as "brian.simms@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "sample.wav"

  Scenario: Sending a document with specified Jurisdictions/Roles scopes who the document will be sent to
    When I fill out the document sending form with:
      | Jurisdictions | Dallas County, Tarrant County |
      | Roles         | Health Officer                |

    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com, brian.ryckbost@example.com |
      | subject       | John Smith sent a document to you                                           |
      | body contains | To view this document                                                       |
    And "brian.simms@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"

    Given I am logged in as "ethan.waldo@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"

    Given I am logged in as "brian.simms@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should not see "sample.wav"

  Scenario: Sending a document with specified Jurisdictions/Organization scopes who the document will be sent to
    When I fill out the document sending form with:
      | Jurisdictions | Dallas County |

    And I press "Send"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"

    And the following users should receive the email:
      | People        | john.smith@example.com                |
      | subject       | John Smith sent a document to you     |
      | body contains | To view this document                 |
    And "ed.mcguyver@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "sample.wav"

    Given I am logged in as "ed.mcguyver@example.com"
    Then I should see "You are not authorized to view this page."