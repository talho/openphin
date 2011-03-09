@ext
Feature: Create a folder tree in documents

  In order to facilitate the sharing of documents
  As I user
  I would like to be able to create a folder tree structure

  Background:
    Given the following administrators exist:
          | admin@dallas.gov | Dallas County |
    And I am logged in as "admin@dallas.gov"
    And I navigate to the ext dashboard page
    And I navigate to "Documents"

  Scenario: See "My Documents" as a leaf with no other folders
    Then I should see "My Documents" in grid row 1 within ".document-folder-tree-grid"
    And the "My Documents" grid row should have the folder-context-icon icon
    And the "My Documents" grid row should not have the folder-shared-icon icon

  Scenario: Create a folder
    When I select the "My Documents" grid row within ".document-folder-tree-grid"
    And I press "Add Folder"
    And I fill in "Folder Name" with "Folder 1"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see "My Documents" in grid row 1 within ".document-folder-tree-grid"
    And I should see "Folder 1" in grid row 2 within ".document-folder-tree-grid"

  Scenario Outline: Check different folder creation scenarios
    Given I create a folder outline with "<outline>"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away
    And I expand the folders "<expand>"
    Then I should see folders in the order "<order>"

    Examples:
    | outline                                             | expand          | order                           |
    | Folder1 Folder2 Folder3 Folder4                     |                 | Folder1 Folder2 Folder3 Folder4 |
    | Folder1>Sub1 Folder2>Sub2                           | Folder1 Folder2 | Folder1 Sub1 Folder2 Sub2       |
    | Folder1>Sub1 Folder1>Sub2 Folder2                   | Folder1         | Folder1 Sub1 Sub2 Folder2       |
    | Folder1>Sub1 Folder1>Sub2 Folder1>Sub3 Sub2>SubSub1 | Folder1 Sub2    | Folder1 Sub1 Sub2 SubSub1 Sub3  |

  Scenario: Edit a folder
    Given I create a folder outline with "Folder1"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away
    And I expand the folders ""
    And I click folder-context-icon on the "Folder1" grid row
    And I click x-menu-item "Edit Folder"
    Then the "Edit Folder" window should be open
    When I fill in "Folder Name" with "Modified"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see "Modified" in grid row 2 within ".document-folder-tree-grid"
    And I should not see "Folder1" in grid row 2 within ".document-folder-tree-grid"

  Scenario: Move folders around the folder tree
    Given I create a folder outline with "Folder1 Folder2>Sub1"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away
    And I expand the folders "Folder2"
    And I select the "Sub1" grid row
    And I click documents-file-action-button "Move Selection"
    Then the "Move Folder" window should be open
    When I select "Folder1" from ext combo "Move to"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see folders in the order "Folder1 Sub1 Folder2"
    And I click documents-file-action-button "Move Selection"
    When I select "My Documents" from ext combo "Move to"
    And I press "Save"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should see folders in the order "Folder1 Folder2 Sub1"

  Scenario: Delete folders
    Given I create a folder outline with "Folder1>Sub1 Folder1>Sub2 Sub2>SubSub1"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away
    And I expand the folders "Folder1"
    And I select the "Sub1" grid row
    And I click documents-file-action-button "Delete Folder"
    And I press "Yes"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should not see "Sub1" in grid row 3
    When I select the "Sub2" grid row
    And I click documents-file-action-button "Delete Folder"
    And I press "Yes"
    And I wait for the "Saving" mask to go away
    And I wait for the "Loading" mask to go away
    Then I should not see "Sub2" in grid row 3
    And folder "SubSub1" should not exist

  Scenario: Navigate folder structure using the icon view
    Given I create a folder outline with "Folder1>Sub1 Folder1>Sub2 Sub1>SubSub1"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away
    And I expand the folders ""
    And I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    And I double-click the "Sub1" folder
    And I wait for the "Loading" mask to go away
    Then the "Sub1" grid row within ".document-folder-tree-grid" should be selected
    When I double-click the "SubSub1" folder
    And I wait for the "Loading" mask to go away
    Then the "SubSub1" grid row within ".document-folder-tree-grid" should be selected
    When I select the "Folder1" grid row
    And I wait for the "Loading" mask to go away
    And I double-click the "Sub2" folder
    And I wait for the "Loading" mask to go away
    Then the "Sub2" grid row within ".document-folder-tree-grid" should be selected

  Scenario: Launch action windows from the various locations
    Given I create a folder outline with "Folder1>Sub1 Folder1>Sub2"
    When I press "Refresh"
    And I wait for the "Loading" mask to go away

    And I press "Add Folder"
    Then the "Add Folder" window should be open
    When I close the active ext window

    And I expand the folders "Folder1"
    And I click folder-context-icon on the "My Documents" grid row
    Then I should see the following ext menu items:
      | name           |
      | Add New Folder |
    And I click x-menu-item "Add New Folder"
    Then the "Add Folder" window should be open
    When I close the active ext window

    And I click folder-context-icon on the "Folder1" grid row
    Then I should see the following ext menu items:
      | name           |
      | Add New Folder |
      | Edit Folder    |
      | Delete Folder  |
    When I click x-menu-item "Add New Folder"
    Then the "Add Folder" window should be open
    When I close the active ext window
    And I click folder-context-icon on the "Folder1" grid row
    And I click x-menu-item "Edit Folder"
    Then the "Edit Folder" window should be open
    And the "Folder Name" field should contain "Folder1"
    When I close the active ext window
    And I click folder-context-icon on the "Folder1" grid row
    And I click x-menu-item "Delete Folder"
    Then the "Delete Folder" window should be open
    When I close the active ext window
    And I select the "Folder1" grid row
    And I click inlineLink "Create New Folder"
    Then the "Add Folder" window should be open
    When I close the active ext window
    And I click inlineLink "Upload New File"
    Then the "New Document" window should be open
    When I close the active ext window
    And I click inlineLink "Move Selection"
    Then the "Move Folder" window should be open
    When I close the active ext window
    And I click inlineLink "Edit Folder"
    Then the "Edit Folder" window should be open
    And the "Folder Name" field should contain "Folder1"
    When I close the active ext window
    And I click inlineLink "Delete Folder"
    Then the "Delete Folder" window should be open
    When I close the active ext window
    
    And I click documents-folder-item "Sub1"
    And I click inlineLink "Edit Folder"
    Then the "Edit Folder" window should be open
    And the "Folder Name" field should contain "Sub1"
