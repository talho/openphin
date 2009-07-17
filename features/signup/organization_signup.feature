@orgsignup
Feature: Signing up for an organization account
In order to allow org members to self-enroll as members of my organization
As a visitor
I want to be able to sign up for an organization account

Background:
Given the following entities exist:
    | Jurisdiction      | Dallas County           |
    | Jurisdiction      | Tarrant County          |
    | Jurisdiction      | Tarrant County          |
    | Jurisdiction      | Tarrant County          |
    | Organization Type | Non-Profit Organization |
And Texas has the following administrators:
    | Keith Gaddis      | keith@texashan.org     |

Scenario: Signing up as an organization
When I signup for an account with the following info:
    | Organization                            | Greater Dallas Salvation Army |
    | Organization Type                       |  Non-Profit Organization |
    | Organization Contact Email              | john@example.com |
    | Organization Distribution Email         | staff@salvationarmydallas.org |
    | Org Password                            | apples                |
    | Org Password confirmation               | apples                |
    | First name of org contact               | John                  |
    | Last name of org contact                | Smith                 |
    | Preferred name                          | Jonathan Smith |
    | What counties operating in              | Dallas County, Tarrant County, Denton County |
    | Preferred language                      | English |
    | Description of org                      | This might be a mission statement |
    | telephoneNumber                         | 5124444444 |
    | fax                                     | 5123333333 |
    | Street                                  | 123 Willow Ave. Suite 34 |
    | City                                    | Dallas |
    | State                                   | TX |
    | ZIP                                     | 22212 |
Then I should see "Thanks for signing your organization up, the email you specified as the organization's contact will receive an email notification upon admin approval of the organization's registration.  Once approval is received, individuals will be able to enroll themselves and associate their account with this organization."
And the following users should receive the email:
    | roles         | Texas / Admin |
    | subject       | User requesting organization signup
    | body contains | Greater Dallas Salvation Army |
    | body contains | Jonathan Smith (john@example.com) |
    | body contains | 5124444444
    | body contains | Dallas County   Tarrant County    Denton County |
    | body contains | Non-Profit Organization |

Given the organization has been approved
Then "john@example.com" should receive the email:
    | subject       | Confirmation of Health Alert Network organization registration    |
    | body contains | Thanks for signing up.  Your users may now begin enrollment.|
And when I self-enroll I should have "Greater Dallas Salvation Army" as a choice of organization affiliation
