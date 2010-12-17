@ext
Feature: Document scheduled backgroundrb task

  In order to keep my system trim of old documents
  As a system administrator
  I want a scheduled task to occur that deletes the old documents and notifies users of documents that will soon expire

  Background:
    Given the following users exist:
      | Bartleby Scrivener | bartleby@example.com | Admin  | Dallas County |
    And delayed jobs are processed
    And I am logged in as "bartleby@example.com"

  Scenario Outline: A 30 day old document in an expiring folder should be deleted
    Given I create a folder outline with "Folder1"
    And I uploaded "spec/fixtures/invitees.csv" to "Folder1" <days> days ago
    When backgroundrb has processed the nightly documents
    Then "invitees.csv" <existence> exist in folder "Folder1"

    Examples:
    | days | existence  |
    | 31   | should not |
    | 30   | should not |
    | 125  | should not |
    | 1    | should     |
    | 29   | should     |

  Scenario: A 25 day old document in an expiring and notifying folder should cause the document owner to be notified of impending deletion
    Given I create a folder outline with "Folder1 Folder2"
    And I uploaded "spec/fixtures/invitees.csv" to "Folder1" 25 days ago
    And I uploaded "spec/fixtures/sample.wav" to "Folder2" 25 days ago
    And I uploaded "spec/fixtures/orglist.csv" to "Folder1" 26 days ago
    When backgroundrb has processed the nightly documents
    Then "bartleby@example.com" should receive the email:
      | subject       | Some of your PHIN documents are soon to expire. |
      | body contains | The following documents will expire in 5 days time: |
      | body contains | "invitees.csv" in folder "Folder1" |
      | body contains | "sample.wav" in folder "Folder2" | 
      | body does not contain | "orglist.csv" in folder "Folder1" |
