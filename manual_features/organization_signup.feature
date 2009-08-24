@orgsignup
Feature: Signing up for an organization account
  In order to allow org members to self-enroll as members of my organization
  As a visitor
  I want to be able to sign up for an organization account

  Background:
    Given the following entities exist:
        | Jurisdiction      | Dallas County           |
        | Jurisdiction      | Texas                   |
        | Jurisdiction      | Tarrant County          |
        | Jurisdiction      | Denton County           |
        | Organization Type | Non-Profit Organization |
        | Role              | Public                  |
    And the following organization administrators exist:
        | keith@texashan.org     | Texas      |

  Scenario: Signing up as an organization when logged in
    Given the following users exist:              
      | Jonathan Smith | john.smith@example.com | Public | Texas |
    And I am logged in as "john.smith@example.com"
    When I signup for an organization account with the following info:
        | Organization                            | Greater Dallas Salvation Army |
        | Distribution Email         | staff@salvationarmydallas.org |
        | What Counties                   | Dallas County, Tarrant County, Denton County |
        | Description                    | This might be a mission statement |
        | Phone                         | 5124444444 |
        | Fax                                     | 5123333333 |
        | Street                                  | 123 Willow Ave. Suite 34 |
        | City                                    | Dallas |
        | State                                   | TX |
        | Zip                                     | 22212 |
    Then I should see "Thanks for signing your organization up, the email you specified as the organization's contact will receive an email notification upon admin approval of the organization's registration.  Once approval is received, individuals will be able to enroll themselves and associate their account with this organization."
    And the following users should receive the email:
        | roles         | Texas / OrgAdmin |
        | subject       | User requesting organization signup |
        | body contains | Greater Dallas Salvation Army |
        | body contains | Jonathan Smith (john.smith@example.com) |
        | body contains | 5124444444 |
        | body contains | Dallas County |
        | body contains | Tarrant County |
        | body contains | Denton County |
        | body contains | Non-Profit Organization |
                                                                                                                                                                                             50,5          Bot

