Feature: A user is going to request a role be added to their role list

Scenario: New user requests a secure role
Given I am a new user
When I visit the new user page
And fill out the new user form
And request a secure role
Then the role is not automatically added to my roles