Feature: Sharing documents with selected scopes

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
    And I have the document "sample.wav" in my inbox
    When I go to the document viewing panel
    And I fill in "Rockstars" for "Share Name"
    And I press "Create Share"
    And I follow "Inbox"
    And I check "sample.wav"
    And I follow "Add to Share"
    And I check "Rockstars"
    And I press "Share"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"

  Scenario: Sending a document directly to a user
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |

    And I press "Invite"
    Then I should be on the document viewing panel
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

  Scenario: Sharing a document with multiple users
    When I fill out the document sharing form with:
      | People | Keith Gaddis, Dan Morrison, Ed McGuyver |

    And I press "Invite"
    Then I should be on the document viewing panel

    And the following users should receive the email:
      | People       | keith.gaddis@example.com, dan.morrison@example.com |
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |
    And "ed.mcguyver@example.com" should not receive an email

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

    Given I am logged in as "dan.morrison@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions shares it with all users within those Jurisdictions
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |

    And I press "Invite"
    Then I should be on the document viewing panel

    And the following users should receive the email:
      | People        | john.smith@example.com, brian.simms@example.com |
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |
    And "ed.mcguyver@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

    Given I am logged in as "brian.simms@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

  Scenario: Sharing a document with specified Jurisdictions/Roles scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County, Tarrant County |
      | Roles         | Health Officer                |

    And I press "Invite"
    Then I should be on the document viewing panel

    And the following users should receive the email:
      | People        | john.smith@example.com, ethan.waldo@example.com, brian.ryckbost@example.com |
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |
    And "brian.simms@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

    Given I am logged in as "ethan.waldo@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav" 

    Given I go to the document viewing panel
    And I am logged in as "brian.simms@example.com"
    When I go to the document viewing panel
    Then I should not see "Rockstars"

  Scenario: Sharing a document with a specified Jurisdictions/Organization scopes who the document will be shared with
    When I fill out the document sharing form with:
      | Jurisdictions | Dallas County |

    And I press "Invite"
    Then I should be on the document viewing panel

    And the following users should receive the email:
      | People        | john.smith@example.com |
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |
    And "ed.mcguyver@example.com" should not receive an email

    Given I am logged in as "john.smith@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    Then I should see "sample.wav"

    Given I am logged in as "ed.mcguyver@example.com"
    When I go to the document viewing panel
    Then I should see "You are not authorized to view this page."

  Scenario: Sharing a document with groups

  Scenario: forwarding documents to another group of recipients as owners
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
    And I check "Make these people owners"
    And I press "Invite"

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I should see "Rockstars"
    And I check "Rockstars"
    And I follow "Invite"
    When I fill out the document sharing form with:
      | People   | Brian Simms |
    And I press "Invite"

    Then I should be on the document viewing panel
    And "brian.simms@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |

    Given I am logged in as "brian.simms@example.com"
    When I go to the Documents page
    And I follow "Rockstars"
    Then I should see "sample.wav"

  Scenario: forwarding documents to another group of recipients who are not owners
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
    And I press "Invite"

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I follow "Rockstars"
    And I check "sample.wav"
    Then I should not see "Invite"

  Scenario: Inviting a user who is already subscribed as a non-owner and promoting them to owner
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
    And I press "Invite"

    Then I should be on the document viewing panel
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I should see "Rockstars"
    And I should not see "Invite" within ".share"

    Given I am logged in as "john.smith@example.com"
    When I go to the document viewing panel
    And I check "Rockstars"
    And I follow "Invite"
    When I fill out the document sharing form with:
      | People   | Keith Gaddis |
    And I check "Make these people owners"
    And I press "Invite"

    Then I should be on the document viewing panel
    And "keith.gaddis@example.com" should receive the email:
      | subject       | John Smith invited you to a share |
      | body contains | To view this channel, go to: |

    Given I am logged in as "keith.gaddis@example.com"
    When I go to the document viewing panel
    And I should see "Rockstars"
    And I should see "Invite" within ".share"
