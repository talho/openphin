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

  Scenario: Viewing documents in shares
    When I go to the document viewing panel
    Then I should see "Shares"
    And I should see "Rockstars"
    And I should not see "keith.jpg"
    When I follow "Rockstars"
    Then I should see "keith.jpg"
    When I follow "keith.jpg"
    Then I should receive the file:
    | Filename      | keith.jpg  |
    | Content Type  | image/jpeg |
