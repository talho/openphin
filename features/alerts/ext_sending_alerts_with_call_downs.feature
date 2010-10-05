@ext
Feature: Sending alerts with call downs

  In order to send an alert with call down options specified
  As an alerter
  Users should receive alerts with call down response options

  Background:
    Given the following entities exists:
      | Role | Health Alert and Communications Coordinator |
    And the role "Health Alert and Communications Coordinator" is an alerter





