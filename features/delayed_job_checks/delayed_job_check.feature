@delayed_job_check
Feature: Check that delayed_job is running

  Test that delayed_job is running and working properly by sending a
  test email.
  
  Background:
    Given the following users exist:
      | John Smith      | john.smith@example.com   | Public | Dallas County |
      | Jill Smith      | jill.smith@example.com   | Admin  | Potter County |
    And I am logged in as "john.smith@example.com"

  Scenario: Send test email to confirm delayed_job is running
    When I go to the delayed job check page"
    Then I should see "Check if delayed_job is running"
    When I fill in "Email" with "jill.smith@example.com"
    And I press "Send Email"
    Then I should see "Test message was successfully sent."
