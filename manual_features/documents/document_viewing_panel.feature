Feature: Using the document viewing panel
  In order to view documents without losing the application view
  As a user
  I should be able to view and open documents

  Background:
    Given the following administrators exist:
      | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    And no documents exist
    And I have a folder named "Rockstars"
    And I have the document "keith.jpg" in "Rockstars"
    And I have been added to the share "Public Stuff"
    And a document "sample.wav" is in the share "Public Stuff"
    And I have the document "PCAAckExample.xml" in my inbox
    When I go to the document viewing panel
    Then I should see "Inbox"
    And I should see "Shares"
    And I should see "Public Stuff"
    And I should see "Folders"
    And I should see "Rockstars"
    And I should not see "keith.jpg"
    And I should not see "sample.wav"
    And I should not see "PCAMessageAlert.xml"
    And I should not see "(Default FactoryUser)"
    And I should not see "(Default FactoryUser,Default FactoryUser)"

  Scenario: Viewing documents in inbox
    When I follow "Inbox"
    Then I should see "PCAAckExample.xml"
    When I follow "PCAAckExample.xml"
    Then I should receive the file:
      | Filename      | PCAAckExample.xml  |
      | Content Type  | text/xml           |
    When I go to the document viewing panel
    When I follow "Inbox"
    Then I should see "PCAAckExample.xml"
    And I should not see "keith.jpg"
    And I should not see "sample.wav"
    And I should not see "PCAMessageAlert.xml"
    When I follow "PCAAckExample.xml"
    And I should receive the file:
      | Filename      | PCAAckExample.xml  |
      | Content Type  | text/xml           |

  Scenario: Viewing documents in lots of folders
    Given I have "10" folders named "Rockstars" with the following documents:
      | keith.jpg |
    When I go to the document viewing panel
    Then I should see "10" folders named "Rockstars"
    And I should not see "keith.jpg"
    And I should not see "sample.wav"
    And I should see "PCAAckExample.xml"
    When I follow "Rockstars10"
    Then I should see "keith.jpg"
    And I should not see "sample.wav"
    And I should not see "PCAMessageAlert.xml"
    And I should not see "PCAAckExample.xml"
    When I follow "keith.jpg"
    Then I should receive the file:
    | Filename      | keith.jpg  |
    | Content Type  | image/jpeg |

  Scenario: Viewing documents in subfolders
    Given I have a folder named "PCA Rocker" within "Rockstars"
    And I have the document "PCAMessageAlert.xml" in "PCA Rocker"
    When I go to the document viewing panel
    Then I should see "PCA Rocker"
    When I follow "PCA Rocker"
    Then I should see "PCAMessageAlert.xml"
    And I should not see "keith.jpg"
    And I should not see "sample.wav"
    And I should not see "PCAAckExample.xml"
    When I follow "PCAMessageAlert.xml"
    Then I should receive the file:
    | Filename      | PCAMessageAlert.xml  |
    | Content Type  | text/xml             |

  Scenario: Viewing documents in shares
    Given I have been added as owner to the share "Public Stuff"
    When I go to the document viewing panel
    When I follow "Public Stuff"
    Then I should see "sample.wav"
    And I should see "(Default FactoryUser)"
    And I should not see "keith.jpg"
    And I should not see "PCAMessageAlert.xml"
    And I should not see "PCAAckExample.xml"
    When I follow "sample.wav"
    Then I should receive the file:
    | Filename      | sample.wav  |
    | Content Type  | application/x-wav |

  Scenario: Viewing owners of a share
    Given I have been added as owner to the share "Public Stuff"
    When I go to the document viewing panel
    When I follow "Public Stuff"
    Then I should see "(Default FactoryUser)"

  Scenario: Viewing multiple owners of a share
    Given I have been added as owner to the share "Public Stuff"
    And I have been added as owner to the share "Public Stuff"
    When I go to the document viewing panel
    When I follow "Public Stuff"
    Then I should see "(Default FactoryUser,Default FactoryUser)"
