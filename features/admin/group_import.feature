Feature: Importing users from a CSV
  In order to migrate groups from an existing HAN/PHIN-like system into OpenPHIN
  As an administrator
  I should be able to use the group importer to create groups and and or update users from a normalized csv file

  Background:
    Given the following entities exist:
      | Jurisdiction | Texas                                       |
      | Jurisdiction | Ector                                       |
      | Jurisdiction | Tarrant                                     |
      | Jurisdiction | Region 6/5 South                            |
      | Role         | Epidemiologist                              |
      | Role         | Health Officer                              |
      | Role         | Health Alert and Communications Coordinator |
    And Texas is the parent jurisdiction of:
      | Ector | Tarrant | Region 6/5 South |
    And the role "Health Alert and Communications Coordinator" is an alerter
    And the following users exist:
      | Boss User      | boss@example.com | Health Alert and Communications Coordinator | Texas            |
      | Andy User      | andy@example.com | Health Alert and Communications Coordinator | Region 6/5 South |
      | Jane User      | jane@example.com | Epidemiologist                              | Region 6/5 South |
      | Jay User       | jay@example.com  | Epidemiologist                              | Tarrant          |
      | John User      | john@example.com | Epidemiologist                              | Ector            |
      | Bob User       | bob@example.com  | Health Officer                              | Ector            |
      | Greg User      | greg@example.com | Epidemiologist                              |                  |
    And the user "Boss User" with the email "boss@example.com" has the role "Health Alert and Communications Coordinator" in "Texas"
    And the user "Boss User" with the email "boss@example.com" has the role "Health Alert and Communications Coordinator" in "Ector"

  Scenario: Importing a well-formatted file
    Given the following file "groups.csv":
    """
    email|jurisdiction|group_name
    jane@example.com| Region 6/5 South| School Nurses
    jay@example.com | Tarrant | School Nurses
    john@example.com| Ector | EctorCoHAN
    bob@example.com | Ector | EctorCoHAN
    """
    When I import the group file "groups.csv"
    Then the group "School Nurses" in "Region 6/5 South" should exist
    And the group "School Nurses" in "Tarrant" should not exist
    And the group "EctorCoHAN" in "Ector" should exist
    And the "School Nurses" group in "Region 6/5 South" should have the following members:
      | User | jane@example.com |
    And the "School Nurses" group in "Region 6/5 South" should not have the following members:
      | User | jay@example.com  |
      | User | john@example.com |
      | User | bob@example.com  |
    And I should see an error "Tarrant - School Nurses"
    And the "EctorCoHAN" group in "Ector" should have the following members:
      | User | john@example.com |
      | User | bob@example.com  |
    And the "EctorCoHAN" group in "Ector" should not have the following members:
      | User | jane@example.com |
      | User | jay@example.com  |

  Scenario: Updating existing groups with new users
    And the following groups for "andy@example.com" exist:
      | Health Officer Group || Health Officer | jane@example.com | Jurisdiction | Region 6/5 South |
    And the following file "groups.csv":
    """
    email|jurisdiction|group_name
    jay@example.com | Region 6/5 South| Health Officer Group
    john@example.com | Ector | Health Officer Group
    """
    When I import the group file "groups.csv"
    Then the "Health Officer Group" group in "Region 6/5 South" should have the following members:
      | User | jane@example.com |
      | User | jay@example.com  |
    Then the "Health Officer Group" group in "Region 6/5 South" should not have the following members:
      | User | john@example.com |
      | User | bob@example.com  |
    Then the "Health Officer Group" group in "Ector" should have the following members:
      | User | john@example.com |
    Then the "Health Officer Group" group in "Ector" should not have the following members:
      | User | jane@example.com |
      | User | jay@example.com  |

  Scenario: Updating existing groups with new users and no_update is specified
    And the following groups for "andy@example.com" exist:
      | Health Officer Group || Health Officer | jane@example.com | Jurisdiction | Region 6/5 South |
    And the following file "groups.csv":
    """
    email|jurisdiction|group_name
    jay@example.com | Region 6/5 South| Health Officer Group
    john@example.com | Ector | Health Officer Group
    """
    When I import the group file "groups.csv" with no update
    Then the "Health Officer Group" group in "Region 6/5 South" should have the following members:
      | User | jane@example.com |
    Then the "Health Officer Group" group in "Region 6/5 South" should not have the following members:
      | User | jay@example.com |
    Then the "Health Officer Group" group in "Ector" should have the following members:
      | User | jane@example.com |
      | User | john@example.com |
    Then the "Health Officer Group" group in "Ector" should not have the following members:
      | User | jay@example.com |
