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

  Scenario: Organization signup form should not display Federal jurisdiction
    When I go to the new organization page
    Then I should not see "Federal" in the "Jurisdictions" dropdown

  Scenario: Signing up as an organization when not logged in
    When I signup for an organization account with the following info:
        | Organization                            | Greater Dallas Salvation Army |
        | Distribution Email                      | staff@salvationarmydallas.org |
        | What Counties                           | Dallas County, Tarrant County, Denton County |
        | Description                             | This might be a mission statement |
        | Name                                    | John Smith            |
        | Email Address                           | john@example.com |
        | Phone Number                            | 5125125112 |
        | Phone                                   | 5124444444 |
        | Fax                                     | 5123333333 |
        | Street                                  | 123 Willow Ave. Suite 34 |
        | City                                    | Dallas |
        | State                                   | TX |
        | Zip                                     | 22212 |
    Then I should see "Thank you for registering your organization with TXPhin. You will receive an email notification at the organization's email address upon administrator approval of the organization's registration.  Once approval is granted, individuals will be able to enroll themselves and associate their account with this organization."
    And "john@example.com" should receive the email:
      | subject       | Confirm your email    |
      | body contains | Thanks for registering your organization |

    When "john@example.com" clicks the organization confirmation link in the email
    Then I should see "Your organization is confirmed.  You will be contacted by your TXPhin administrator when your registration is approved."
    And "Greater Dallas Salvation Army" is confirmed

  Scenario: Signing up as an organization when not logged in should display error when form is blank
    When I signup for an organization account with the following info:
        | Fax                            | 5124444444 |
    Then I should see "11 errors prohibited this organization from being saved"
    And I should see "There were problems with the following fields:"
    And I should see "Organization name can't be blank"
    And I should see "Distribution email can't be blank"
    And I should see "Postal code can't be blank"
    And I should see "Street can't be blank"
    And I should see "Phone can't be blank"
    And I should see "Description of organization can't be blank"
    And I should see "City can't be blank"
    And I should see "Contact person's name can't be blank"
    And I should see "Contact person's email can't be blank"
    And I should see "Contact person's phone can't be blank"
    And I should see "State can't be blank"
