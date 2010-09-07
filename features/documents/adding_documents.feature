  Feature: Adding documents to document sharing
    In order to share documents to other users
    As a user
    I should be able to add documents to my store

  Background:
    Given the following administrators exist:
      | admin@dallas.gov | Dallas County |
      | admin@potter.gov | Potter County |
    And I am logged in as "admin@dallas.gov"
    And I go to the dashboard page

  Scenario: Adding a document to private storage
    Given I have a folder named "Rockstars"

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#upload_document" from the documents toolbar
    Then I wait for the "#document_file" element to load
    And I attach the file "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "upload"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"
    And I will confirm on next step
    When I download the file "keith.jpg"
    Then I should see "Success" within the alert box

  Scenario: Adding a document to a folder that already contains a file by the same name
    Given I have a folder named "Rockstars"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#upload_document" from the documents toolbar
    Then I wait for the "#document_file" element to load
    And I attach the file "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "upload"
    Then I wait for the "#document_progress_panel" element to finish

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#upload_document" from the documents toolbar
    Then I wait for the "#document_file" element to load
    And I attach the file "spec/fixtures/keith.jpg" to "Upload Document"
    And I press "upload"
    Then I should see "File name is already in use" within the confirmation box
    And I should see "keith.jpg"

  Scenario: Viewing documents
    Given I have the document "keith.jpg" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    Then I should see "keith.jpg"
    And I will confirm on next step
    When I download the file "keith.jpg"
    Then I should see "Success" within the alert box

  Scenario: Creating folders to organize documents
    When I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#new_media_folder" from the documents toolbar
    And I fill in "Folder Name" with "Important"
    And I press "Create Folder"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "Important"

    When I select "#new_media_folder" from the documents toolbar
    And I fill in "Folder Name" with "Less Important"
    And I press "Create Folder"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "Less Important"

  Scenario: Creating nested folders to organize documents
    When I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#new_media_folder" from the documents toolbar
    And I fill in "Folder Name" with "Everything"
    And I press "Create Folder"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "Everything"

    When I follow "Everything"
    Then I wait for the "#document_progress_panel" element to finish
    And I select "#new_document_folder" from the documents toolbar
    And I wait for the "#folder_document_name" element to load
    And I fill in "Folder Name" with "Some Things" within "#new_document_folder_container"
    And I press "Create Folder" within "#new_document_folder_container"
    Then I wait for the "#document_progress_panel" element to finish
    And I toggle the folder "Everything"
    When I follow "Some Things"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "Contents of Some Things"

  Scenario: Moving a document into a folder
    Given I have a folder named "Rockstars"
    And I have the document "keith.jpg" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"
    When I check "keith.jpg"
    And I select "#move_edit" from the documents toolbar
    And I wait for the "div#move_edit_panel form.edit_document" element to load
    And I select "Rockstars" from "Folder"
    And I press "Move to Folder"
    Then I wait for the "#document_progress_panel" element to finish
    When I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"

    When I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"

  Scenario: Updating a document
    Given I have the document "keith.jpg" in my inbox
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "keith.jpg"
    And I select "#move_edit" from the documents toolbar
    And I wait for the "div#move_edit_panel form.edit_document" element to load
    And I attach the file "spec/fixtures/sample.wav" to "Upload a new version"
    And I press "Update"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"
    And I should see "sample.wav"
    
  Scenario: Deleting a document from the inbox
    Given no documents exist
    And I have the document "keith.jpg" in my inbox

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"
    And I check "keith.jpg"
    And I will confirm on next step
    And I select "#delete_file" from the documents toolbar
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"
    And the file "keith.jpg" in the inbox does not exist

  Scenario: Deleting a document from a folder
    Given no documents exist
    And I have a folder named "Rockstars"
    And I have the document "keith.jpg" in "Rockstars"

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"
    And I check "keith.jpg"
    And I will confirm on next step
    And I select "#delete_file" from the documents toolbar
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"
    And the file "keith.jpg" in folder "Rockstars" does not exist  

  Scenario: Deleting a folder with documents
    Given no documents exist
    And I have a folder named "Rockstars"
    And I have the document "keith.jpg" in "Rockstars"

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Rockstars"
    Then I wait for the "#document_progress_panel" element to finish
    And I should see "keith.jpg"

    And I check "Rockstars"
    And I will confirm on next step
    And I select "#delete" from the documents toolbar
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "Rockstars"
    And the file "keith.jpg" and folder "Rockstars" do not exist

  Scenario: Updating a document concurrently to another user updating the same document
    Given I have the document "keith.jpg" in my inbox
    And I created the share "Docs"
    And "admin@potter.gov" has been added as owner to the share "Docs"

    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Inbox"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "keith.jpg"
    And I select "#add_to_share" from the documents toolbar
    And I wait for the "div#share div#edit" element to load
    And I check "Docs"
    And I press "Share"
    Then I wait for the "#document_progress_panel" element to finish

    When I follow "Docs"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "keith.jpg"
    And I select "#move_edit" from the documents toolbar
    And I wait for the "div#move_edit_panel form.edit_document" element to load
    And I attach the file "spec/fixtures/sample.wav" to "Upload a new version"
    
    Given session name is "admin_session"
    And I am logged in as "admin@potter.gov"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Docs"
    Then I wait for the "#document_progress_panel" element to finish
    And I check "keith.jpg"
    And I select "#move_edit" from the documents toolbar
    And I wait for the "div#move_edit_panel form.edit_document" element to load
    And I attach the file "spec/fixtures/invitees.csv" to "Upload a new version"
    And I press "Update"

    Given quit session name "admin_session"
    Given session name is "default"
    And I press "Update"

    Then I should see "Another user recently updated the document you are attempting to update to invitees.csv.  Please try again." within the alert box
    And I sign out
    And I am logged in as "admin@dallas.gov"
    When I go to the dashboard page
    And I follow "Documents"
    Then I wait for the "#document_progress_panel" element to finish
    And I follow "Docs"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"
    And I should not see "sample.wav"
    And I should see "invitees.csv"

    When I check "invitees.csv"
    And I select "#move_edit" from the documents toolbar
    And I wait for the "div#move_edit_panel form.edit_document" element to load
    And I attach the file "spec/fixtures/sample.wav" to "Upload a new version"
    And I press "Update"
    Then I wait for the "#document_progress_panel" element to finish
    And I should not see "keith.jpg"
    And I should not see "invitees.csv"
    And I should see "sample.wav"
    
  Scenario: Verifying mime type validation during adding a document to private storage
    Given I have a folder named "Rockstars"
    When I go to the document viewing panel
    And I follow "Rockstars"
    
    And I attach the fixture file at "fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"
    Then I should see "keith.jpg"

    And I attach the fixture file at "fixtures/sample.wav" to "Upload Document"
    And I press "Upload"
    Then I should see "sample.wav"

    And I attach the fixture file at "fixtures/invitees.csv" to "Upload Document"
    And I press "Upload"
    Then I should see "invitees.csv"

    And I attach the fixture file at "fixtures/cygwin-ldd.exe" to "Upload Document"
    And I press "Upload"
    Then I should not see "cygwin-ldd.exe"
    And I should see "Filetype not permitted"

  Scenario: Scanning uploaded files for viruses
    Given I have a folder named "Badthings"
    And ClamAV is loaded
    
    When I go to the document viewing panel
    And I follow "Badthings"
    And I attach the fixture file at "fixtures/virus.doc" to "Upload Document"
    And I press "Upload"
    Then I should see "Virus detected"

    When I go to the document viewing panel
    And I follow "Badthings"
    And I attach the fixture file at "fixtures/keith.jpg" to "Upload Document"
    And I press "Upload"
    Then I should see "keith.jpg"
