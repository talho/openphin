Feature: Sharing documents with selected scopes

  In order to send documents to groups of users
  As a user
  I can send documents

  Background:
    Given the following entities exists:
      | Jurisdiction | Dallas County         |
      | Jurisdiction | Tarrant County        |
      | Jurisdiction | Wise County           |
      | Jurisdiction | Potter County         |
      | Jurisdiction | Texas                 |
      | Role         | Health Officer        |
      | Role         | Immunization Director |
      | Role         | Epidemiologist        |
      | Role         | WMD Coordinator       |
    And the following users exist:
      | John Smith      | john.smith@example.com     | Health Officer  | Dallas County  |
      | Brian Simms     | brian.simms@example.com    | Epidemiologist  | Dallas County  |
      | Ed McGuyver     | ed.mcguyver@example.com    | Public          | Dallas County  |
      | Ethan Waldo     | ethan.waldo@example.com    | Health Officer  | Tarrant County |
      | Keith Gaddis    | keith.gaddis@example.com   | Epidemiologist  | Wise County    |
      | Jason Phipps    | jason.phipps@example.com   | WMD Coordinator | Potter County  |
      | Dan Morrison    | dan.morrison@example.com   | Health Officer  | Ottawa County  | 
      | Brian Ryckbost  | brian.ryckbost@example.com | Health Officer  | Tarrant County |
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

    And the role "Health Officer" is an alerter
    And I am logged in as "john.smith@example.com"
    And I am allowed to send alerts
    And I have the document "sample.wav" in my root folder
    When I go to the Documents page
    And I follow "Share"

  Scenario: Sending an alert directly to a user
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
      
    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |
   
    Given I am logged in as "keith.gaddis@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

  Scenario: Sharing a document with multiple users
    When I fill out the document sharing form with:
      | People | Keith Gaddis, Dan Morrison |

    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page
  
    And the following users should receive the email:
      | People       | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

    Given I am logged in as "dan.morrison@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions shares it with all users within those Jurisdictions
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |
  
    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page

    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com, ed.mcguyver@example.com |
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |

    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"
    
    Given I am logged in as "brian.simms@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions/Roles scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County, Tarrant County |

    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page

    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com |
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |
   
    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

    Given I am logged in as "ethan.waldo@example.com"
    When I go to the Documents page
    Then I should see "sample.wav" 
   
    Scenario: Sharing a document with a specified Jurisdictions/Organization scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |
  
    And I press "Share"
    Then I should see "Successfully shared the document"
    And I should be on the Documents page

    And the following users should receive the email:
      | People        | john.smith@example.com, ed.mcguyver@example.com |
      | subject       | John Smith shared a document with you |
      | body contains | To view this document |

    Given I am logged in as "john.smith@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"
    
    Given I am logged in as "ed.mcguyver@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"

  Scenario: forwarding documents to another group of recipients
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
    And I press "Share"

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"
    And I follow "Share"
    When I fill out the document sharing form with:
      | People   | Brian Simms |
    And I press "Share"

    Then I should see "Successfully shared the document"
    And "brian.simms@example.com" should receive the email:
       | subject       | John Smith shared a document with you |
       | body contains | To view this document |

    Given I am logged in as "brian.simms@example.com"
    When I go to the Documents page
    Then I should see "sample.wav"
    