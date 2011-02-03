Feature: User change MyAccount password
A user can change his/her password
As a PHIN user
I should be able to change his/her password

Background:
  Given the following entities exists:
    | Jurisdiction | Texas          |
    | Role         | Health Officer |
  And the following users exist:
    | Tex Ho       | tex.ho@example.com    | Health Officer  | Texas    |
  When delayed jobs are processed

Scenario: Password and Confirm Password must match
  Given I am logged in as "tex.ho@example.com"
  And I go to the ext dashboard page
  And I navigate to "My Account > Change Password"

  # confirm mismatch
  When I edit my password to "Andre1" and confirm with "Andrw1"
  And the "Confirm password" field should be invalid

  # missing digit
  When I edit my password to "Andrew" and confirm with "Andrew"
  And the "Password" field should be invalid

  # missing uppercase letter
  When I edit my password to "andre1" and confirm with "andre1"
  And the "Password" field should be invalid

  # missing lowercase letter
  When I edit my password to "ANDRE9" and confirm with "ANDRE9"
  And the "Password" field should be invalid

  # password change successful
  When I edit my password to "Andrew5" and confirm with "Andrew5"
  Then I should have "#flash-msg" within ".x-box-item"
  And I should not see "Password must" within "#flash-msg"
  And I should see "Profile information saved"
