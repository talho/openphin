@delayed_job_check
Feature: Check that delayed_job is running

  Test that delayed_job is running and working properly by sending a
  test email.
  
  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Admin  | Dallas County |
      | Jill Smith      | jill.smith@example.com   | Public | Potter County |
    And delayed jobs are processed

  Scenario: Send test email to confirm delayed_job is running
    When I am logged in as "john.smith@example.com"
    And I go to the delayed job check page"
    Then I should see "Check if delayed_job is running"
    When I fill in "Email" with "jill.smith@example.com"
    And I press "Send Email"
    Then I should see "Test message was successfully sent."
    And "jill.smith@example.com" should receive the email:
      | subject | Delayed Job Check |

  Scenario: Check that only admin can check delayed_job is running
    When I am logged in as "jill.smith@example.com"
    And I go to the delayed job check page"
    Then I should see "That resource does not exist or you do not have access to it."
