@ext
Feature: Spawning a new tab checking

  I want to be create a new forums tab
  As anyone
  I want my new tab to be identical
  
  Background:
    When I prepare for new tab tests
    
  Scenario: I create a new tab
    When I create a new tab
    Then I see two forums tabs