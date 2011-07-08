Feature: Application layout should have communications, portal & application toolbars
  As a user
  I want to see applications that are important to me in the portal toolbar and
  functions specific to the application in the application toolbar and
  communications and utility functions in the communication toolbar
  So that I can navigate the OpenPHIN portal with ease

  Background:
    Given the following entities exist:
      | Jurisdiction  | Texas           |
      | Jurisdiction  | Dallas County   |
      | Role          | Health Official |
    And the following users exist:
      | Martin Fowler | martin@example.com | Health Official | Dallas County |
    And Texas has the following administrators:
      | Joe Smith      | joe.smith@example.com |
    And an article exists
    And an article exists
    And an article exists
    And an article exists
    And an article exists

  Scenario: Viewing the portal and comm toolbar as a user
    Given I am logged in as "martin@example.com"
    When I go to the dashboard page
    Then I should see the following menu:
      | name | portal_toolbar |
      | item | HAN            |
      | item | FAQs           |
      | item | Tutorials      |
    And I should see the following menu:
      | name | comm_toolbar |
      | item | Calendar     |
      | item | Chat         |
      | item | Documents    |
      | item | Links        |
    #And I should see 4 "article" sections

  Scenario: Seeing the Administrator menu as an admin
    Given I am logged in as "joe.smith@example.com"
    When I go to the dashboard page
    And I follow "Admin"
    Then I should see the following menu:
      | name | app_toolbar        |
      | item | Manage Roles       |
      | item | Manage Groups      |
      | item | Manage Users       |
      | item | Manage Invitations |

  Scenario: Non-admins should not see the Admin link
    Given I am logged in as "martin@example.com"
    When I go to the dashboard page
    Then I should not see a "Admin" link

  Scenario: Add a User should show the admin toolbar
    Given I am logged in as "joe.smith@example.com"
    When I go to the admin add user page
    Then I should see the following menu:
      | name         | app_toolbar        |
      | item         | Manage Roles       |
      | item         | Manage Groups      |
      | current item | Manage Users       |
      | item         | Manage Invitations |
