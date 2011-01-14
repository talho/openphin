Feature: Sending alerts across jurisdictions
  In order to meet PHIN obligations by keeping HAN Coordinators informed
  As an alerter
  I automatically inform HAN Coordinators of cross-jurisdictional alerts

Background:
  Given the following entities exists:
    | Role         | Health Alert and Communications Coordinator |
    | Role         | Epidemiologist                              |
    | Role         | Health Officer                              |
    | Role         | Bioterrorism Coordinator                    |
  And Federal is the parent jurisdiction of:
    | Texas |
  And Texas is the parent jurisdiction of:
    | Region 1 | Region 2 |
  And Region 1 is the parent jurisdiction of:
    | Dallas County | Tarrant County |
  And Region 2 is the parent jurisdiction of:
    | Potter County |
  And the following users exist:
     | Fed Hacc        | fed.hacc@example.com    | Health Alert and Communications Coordinator | Federal         |
     | Tex Hacc        | tex.hacc@example.com    | Health Alert and Communications Coordinator | Texas           |
     | Tex Biot        | tex.biot@example.com    | Bioterrorism Coordinator                    | Texas           |
     | Reg1 Hacc       | reg1.hacc@example.com   | Health Alert and Communications Coordinator | Region 1        |
     | Reg1 Biot       | reg1.biot@example.com   | Bioterrorism Coordinator                    | Region 1        |
     | Reg2 Hacc       | reg2.hacc@example.com   | Health Alert and Communications Coordinator | Region 2        |
     | Reg2 Biot       | reg2.biot@example.com   | Bioterrorism Coordinator                    | Region 2        |
     | Dal Hacc        | dal.hacc@example.com    | Health Alert and Communications Coordinator | Dallas County   |
     | Dal Epid        | dal.epid@example.com    | Epidemiologist                              | Dallas County   |
     | Tar Hacc        | tar.hacc@example.com    | Health Alert and Communications Coordinator | Tarrant County  |
     | Tar Epid        | tar.epid@example.com    | Epidemiologist                              | Tarrant County  |
     | Pot Hacc        | pot.hacc@example.com    | Health Alert and Communications Coordinator | Potter County   |
     | Pot Epid        | pot.epid@example.com    | Epidemiologist                              | Potter County   |

  And the role "Health Alert and Communications Coordinator" is an alerter

#=============================================================
#================= SENDING FROM A COUNTY =====================
#=============================================================

  Scenario Outline: Sending Cross-Jurisdictional alerts to Jurisdictions from a County-level jurisdiction
   Given a sent alert with:
     | author                    | Dal Hacc               |
     | from_jurisdiction         | Dallas County          |
     | acknowledge               | false                  |
     | communication methods     | Email                  |
     | delivery time             | 72 hours               |
     | not_cross_jurisdictional  | false                  |
     | jurisdictions             | <target_jurisdictions> |

   Then the following users should receive the alert email:
     | People | <recipients> |
   Then the following users should not receive any emails
     | emails | <non_recipients> |

   Scenarios:
     | target_jurisdictions          | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
     | Dallas County                 | dal.hacc@example.com, dal.epid@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Tarrant County                | dal.hacc@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | dal.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Potter County                 | dal.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Region 1                      | dal.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Texas                         | dal.hacc@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Dallas County, Tarrant County | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Dallas County, Potter County  | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Dallas County, Region 1       | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Dallas County, Texas          | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Tarrant County, Potter County | dal.hacc@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Tarrant County, Region 1      | dal.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, tar.hacc@example.com, tar.epid@example.com | dal.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Tarrant County, Texas         | dal.hacc@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.hacc@example.com, tex.biot@example.com | dal.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
     | Potter County, Region 1       | dal.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
     | Potter County, Texas          | dal.hacc@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
     | Region 1, Texas               | dal.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, tex.biot@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Roles and Jurisdictions from a County-level jurisdiction
   Given a sent alert with:
     | author                    | Dal Hacc               |
     | from_jurisdiction         | Dallas County          |
     | acknowledge               | false                  |
     | communication methods     | Email                  |
     | delivery time             | 72 hours               |
     | not_cross_jurisdictional  | false                  |
     | jurisdictions             | <target_jurisdictions> |
     | roles                     | <target_roles>         |
   Then the following users should receive the alert email:
     | People | <recipients> |
   Then the following users should not receive any emails
     | emails | <non_recipients> |

   Scenarios:
     | target_jurisdictions          | target_roles                             | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
     |                               | Epidemiologist                           | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
     |                               | Epidemiologist, Bioterrorism Coordinator | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | fed.hacc@example.com |
     | Dallas County                 | Epidemiologist                           | dal.epid@example.com | dal.hacc@example.com, tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Dallas County, Tarrant County | Epidemiologist                           | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, reg1.hacc@example.com, tar.hacc@example.com | pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Dallas County, Potter County  | Epidemiologist                           | dal.hacc@example.com, dal.epid@example.com, pot.epid@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
     | Dallas County, Region 1       | Epidemiologist                           | dal.epid@example.com | dal.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Dallas County, Texas          | Epidemiologist                           | dal.epid@example.com | dal.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Tarrant County                | Epidemiologist                           | dal.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.hacc@example.com | dal.epid@example.com, pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Tarrant County, Potter County | Epidemiologist                           | dal.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, tex.biot@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
     | Tarrant County, Region 1      | Epidemiologist                           | dal.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.hacc@example.com | dal.epid@example.com, pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Tarrant County, Texas         | Epidemiologist                           | dal.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.hacc@example.com | dal.epid@example.com, pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |     
     | Potter County                 | Epidemiologist                           | dal.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
     | Potter County, Region 1       | Epidemiologist                           | dal.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
     | Potter County, Texas          | Epidemiologist                           | dal.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
     | Region 1                      | Bioterrorism Coordinator                 | dal.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com | dal.epid@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
     | Region 1, Texas               | Bioterrorism Coordinator                 | dal.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com, tex.biot@example.com, tex.hacc@example.com | dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
     | Texas                         | Bioterrorism Coordinator                 | dal.hacc@example.com, reg1.hacc@example.com, tex.biot@example.com, tex.hacc@example.com | dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Groups and Jurisdictions from a County-level jurisdiction
    Given the following groups for "dal.hacc@example.com" exist:
     #| name             | jurisdictions                                | roles                    | users                                      | scope        | owner_jurisdiction
      | pott_tarr        | Potter County, Tarrant County                |                          |                                            | Personal     | Dallas County |
      | reg2_biot        | Region 2                                     | Bioterrorism Coordinator |                                            | Jurisdiction | Dallas County |
      | pott_epid        | Potter County                                | Epidemiologist           |                                            | Personal     | Dallas County |
      | cool_dudes       |                                              |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | counties         | Dallas County, Potter County, Tarrant County |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | epid_and_texbiot |                                              | Epidemiologist           | tex.biot@example.com                       | Personal     | Dallas County |
    And a sent alert with:
      | author                    | Dal Hacc               |
      | from_jurisdiction         | Dallas County          |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | groups                    | <target_groups>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions | target_groups  | recipients           | non_recipients                                                                                                                                                                                                                                                             |
      |                | pott_tarr        | dal.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1       | pott_epid        | dal.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County  | reg2_biot        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, tex.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Dallas County  | cool_dudes       | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, pot.epid@example.com, pot.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                | counties         | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      |                | epid_and_texbiot | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Individuals and Jurisdictions from a County-level jurisdiction
    Given a sent alert with:
      | author                    | Dal Hacc               |
      | from_jurisdiction         | Dallas County          |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | emails                    | <target_emails>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | target_emails                               | recipients           | non_recipients                                                                                                                                                                                                                                                             |
      |                               | dal.epid@example.com                        | dal.epid@example.com, dal.hacc@example.com | tar.epid@example.com, pot.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | tar.epid@example.com                        | dal.hacc@example.com, tar.epid@example.com, tar.hacc@example.com, reg1.hacc@example.com | dal.epid@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | pot.epid@example.com                        | dal.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com | dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com                       | dal.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com | dal.epid@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | tex.biot@example.com                        | dal.hacc@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | dal.epid@example.com, reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, dal.hacc@example.com  | dal.hacc@example.com, dal.epid@example.com | reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, tar.epid@example.com  | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com | reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tex.hacc@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, pot.epid@example.com  | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | reg1.biot@example.com, tar.epid@example.com, tar.hacc@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, reg1.biot@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, tex.biot@example.com  | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | tar.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | pot.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.epid@example.com, tar.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | reg1.biot@example.com                       | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | tex.biot@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Tarrant County                | dal.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Potter County                 | dal.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.epid@example.com, tar.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1                      | dal.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Texas                         | dal.epid@example.com                        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |


#=============================================================
#================= SENDING FROM A REGION =====================
#=============================================================

  Scenario Outline: Sending Cross-Jurisdictional alerts to Jurisdictions from a Region-level jurisdiction
   Given a sent alert with:
     | author                    | Reg1 Hacc              |
     | from_jurisdiction         | Region 1               |
     | acknowledge               | false                  |
     | communication methods     | Email                  |
     | delivery time             | 72 hours               |
     | not_cross_jurisdictional  | false                  |
     | jurisdictions             | <target_jurisdictions> |
   Then the following users should receive the alert email:
     | People | <recipients> |
   Then the following users should not receive any emails
     | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
      | Dallas County                 | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Potter County                 | reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1                      | reg1.hacc@example.com, reg1.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Region 2                      | reg1.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Texas                         | reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Dallas County, Tarrant County | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County, Potter County  | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County, Region 1       | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com | tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Dallas County, Texas          | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tex.hacc@example.com, tex.biot@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Tarrant County, Potter County | reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Tarrant County, Region 1      | reg1.hacc@example.com, reg1.biot@example.com, tar.hacc@example.com, tar.epid@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Tarrant County, Texas         | reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Potter County, Region 1       | reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Potter County, Texas          | reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Region 1, Texas               | reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |

  Scenario Outline: Sending Cross-Jurisdictional alerts to Roles and Jurisdictions from a Region-level jurisdiction
    Given a sent alert with:
      | author                    | Reg1 Hacc              |
      | from_jurisdiction         | Region 1               |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | roles                     | <target_roles>         |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | target_roles                             | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
      |                               | Epidemiologist                           | reg1.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, dal.hacc@example.com, tar.hacc@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | Epidemiologist, Bioterrorism Coordinator | reg1.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, dal.hacc@example.com, tar.hacc@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | fed.hacc@example.com |
      | Dallas County, Tarrant County | Epidemiologist                           | reg1.hacc@example.com, dal.epid@example.com, tar.epid@example.com, dal.hacc@example.com, tar.hacc@example.com | pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Dallas County, Potter County  | Epidemiologist                           | reg1.hacc@example.com, dal.epid@example.com, dal.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Dallas County, Region 1       | Epidemiologist                           | reg1.hacc@example.com, dal.epid@example.com, dal.hacc@example.com | reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Dallas County, Texas          | Epidemiologist                           | reg1.hacc@example.com, dal.epid@example.com, dal.hacc@example.com | reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Tarrant County                | Epidemiologist                           | reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | dal.hacc@example.com, dal.epid@example.com, pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Tarrant County, Potter County | Epidemiologist                           | reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tex.biot@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Tarrant County, Texas         | Epidemiologist                           | reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | dal.hacc@example.com, dal.epid@example.com, pot.epid@example.com, tex.biot@example.com, pot.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Potter County                 | Epidemiologist                           | reg1.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Potter County, Region 1       | Epidemiologist                           | reg1.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Potter County, Texas          | Epidemiologist                           | reg1.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Region 1                      | Bioterrorism Coordinator                 | reg1.biot@example.com | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, fed.hacc@example.com |
      | Region 1, Texas               | Bioterrorism Coordinator                 | reg1.hacc@example.com, reg1.biot@example.com, tex.biot@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Texas                         | Bioterrorism Coordinator                 | reg1.hacc@example.com, tex.biot@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Groups and Jurisdictions from a Region-level jurisdiction
    Given the following groups for "reg1.hacc@example.com" exist:
     #| name             | jurisdictions                                | roles                    | users                                      | scope        | owner_jurisdiction
      | pott_tarr        | Potter County, Tarrant County                |                          |                                            | Personal     | Dallas County |
      | reg2_biot        | Region 2                                     | Bioterrorism Coordinator |                                            | Jurisdiction | Dallas County |
      | pott_epid        | Potter County                                | Epidemiologist           |                                            | Personal     | Dallas County |
      | cool_dudes       |                                              |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | counties         | Dallas County, Potter County, Tarrant County |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | epid_and_texbiot |                                              | Epidemiologist           | tex.biot@example.com                       | Personal     | Dallas County |
    And a sent alert with:
      | author                    | Reg1 Hacc              |
      | from_jurisdiction         | Region 1               |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | groups                    | <target_groups>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions | target_groups  | recipients           | non_recipients                                                                                                                                                                                                                                                             |
      |                | pott_tarr        | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1       | pott_epid        | pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County  | reg2_biot        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, tex.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Dallas County  | cool_dudes       | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, pot.epid@example.com, pot.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                | counties         | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      |                | epid_and_texbiot | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Individuals and Jurisdictions from a Region-level jurisdiction
    Given a sent alert with:
      | author                    | Reg1 Hacc              |
      | from_jurisdiction         | Region 1               |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | emails                    | <target_emails>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | target_emails                               | recipients                                                        | non_recipients                                                                                                                                                                                                                |
      |                               | tar.epid@example.com                        | reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, pot.epid@example.com, pot.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | pot.epid@example.com                        | reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com                       | reg1.biot@example.com, reg1.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | tex.biot@example.com                        | reg1.hacc@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, tar.epid@example.com  | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com | reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tex.hacc@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com, pot.epid@example.com | reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com, dal.epid@example.com | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com, tex.biot@example.com | reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | tar.epid@example.com                        | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | pot.epid@example.com                        | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.epid@example.com, tar.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | reg1.biot@example.com                       | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County                 | tex.biot@example.com                        | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tex.hacc@example.com, tex.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Tarrant County                | reg1.biot@example.com                       | reg1.hacc@example.com, reg1.biot@example.com, tar.epid@example.com, tar.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Potter County                 | reg1.biot@example.com                       | reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 2                      | reg1.biot@example.com                       | reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Texas                         | reg1.biot@example.com                       | reg1.hacc@example.com, reg1.biot@example.com, tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |


#=============================================================
#============== SENDING FROM THE STATE LEVEL =================
#=============================================================

  Scenario Outline: Sending Cross-Jurisdictional alerts to Jurisdictions from a State-level jurisdiction
   Given a sent alert with:
     | author                    | Tex Hacc               |
     | from_jurisdiction         | Texas                  |
     | acknowledge               | false                  |
     | communication methods     | Email                  |
     | delivery time             | 72 hours               |
     | not_cross_jurisdictional  | false                  |
     | jurisdictions             | <target_jurisdictions> |
   Then the following users should receive the alert email:
     | People | <recipients> |
   Then the following users should not receive any emails
     | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
      | Dallas County                 | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1                      | tex.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Texas                         | tex.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Dallas County, Tarrant County | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County, Potter County  | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County, Region 1       | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Dallas County, Texas          | tex.hacc@example.com, tex.biot@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Tarrant County, Potter County | tex.hacc@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Tarrant County, Region 1      | tex.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, tar.hacc@example.com, tar.epid@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Tarrant County, Texas         | tex.hacc@example.com, tex.biot@example.com, reg1.hacc@example.com, tar.hacc@example.com, tar.epid@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |
      | Potter County, Region 1       | tex.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Potter County, Texas          | tex.hacc@example.com, tex.biot@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Region 1, Texas               | tex.hacc@example.com, tex.biot@example.com, reg1.hacc@example.com, reg1.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, pot.hacc@example.com, pot.epid@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Roles and Jurisdictions from a State-level jurisdiction
    Given a sent alert with:
      | author                    | Tex Hacc               |
      | from_jurisdiction         | Texas                  |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | roles                     | <target_roles>         |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | target_roles                             | recipients                                 | non_recipients                                                                                                                                                                                                                                       |
      |                               | Epidemiologist                           | tex.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, dal.hacc@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com | reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | Epidemiologist, Bioterrorism Coordinator | tex.hacc@example.com, dal.epid@example.com, tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, dal.hacc@example.com, tar.hacc@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com | fed.hacc@example.com |
      | Dallas County                 | Epidemiologist                           | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com | tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, reg2.hacc@example.com, fed.hacc@example.com |
      | Dallas County, Potter County  | Epidemiologist                           | tex.hacc@example.com, dal.epid@example.com, dal.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, reg1.hacc@example.com, reg2.hacc@example.com | reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, fed.hacc@example.com |
      | Dallas County, Region 1       | Epidemiologist                           | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com | tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, reg2.hacc@example.com, fed.hacc@example.com |
      | Dallas County, Texas          | Epidemiologist                           | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com | tar.epid@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, reg2.hacc@example.com, fed.hacc@example.com |
      | Region 1                      | Bioterrorism Coordinator                 | tex.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tex.biot@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Region 1, Texas               | Bioterrorism Coordinator                 | tex.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Texas                         | Bioterrorism Coordinator                 | tex.biot@example.com | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |

    
  Scenario Outline: Sending Cross-Jurisdictional alerts to Groups and Jurisdictions from a State-level jurisdiction
    Given the following groups for "tex.hacc@example.com" exist:
     #| name             | jurisdictions                                | roles                    | users                                      | scope        | owner_jurisdiction
      | pott_tarr        | Potter County, Tarrant County                |                          |                                            | Personal     | Dallas County |
      | reg2_biot        | Region 2                                     | Bioterrorism Coordinator |                                            | Jurisdiction | Dallas County |
      | pott_epid        | Potter County                                | Epidemiologist           |                                            | Personal     | Dallas County |
      | cool_dudes       |                                              |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | counties         | Dallas County, Potter County, Tarrant County |                          | tex.biot@example.com, pot.epid@example.com | Global       | Dallas County |
      | epid_and_texbiot |                                              | Epidemiologist           | tex.biot@example.com                       | Personal     | Dallas County |
    And a sent alert with:
      | author                    | Tex Hacc               |
      | from_jurisdiction         | Texas                  |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | groups                    | <target_groups>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions | target_groups  | recipients           | non_recipients                                                                                                                                                                                                                                                             |
      |                | pott_tarr        | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Region 1       | pott_epid        | pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.hacc@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      | Dallas County  | reg2_biot        | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.hacc@example.com | tar.hacc@example.com, tar.epid@example.com, pot.hacc@example.com, pot.epid@example.com, tex.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      |                | cool_dudes       | reg2.hacc@example.com, tex.hacc@example.com, tex.biot@example.com, pot.epid@example.com, pot.hacc@example.com | reg1.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, tar.hacc@example.com, tar.epid@example.com, reg1.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                | counties         | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |
      |                | epid_and_texbiot | dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg2.hacc@example.com, tex.hacc@example.com, pot.epid@example.com, pot.hacc@example.com, tar.hacc@example.com, tar.epid@example.com, tex.biot@example.com | reg2.biot@example.com, reg1.biot@example.com, fed.hacc@example.com |


  Scenario Outline: Sending Cross-Jurisdictional alerts to Individuals and Jurisdictions from a State-level jurisdiction
    Given a sent alert with:
      | author                    | Tex Hacc               |
      | from_jurisdiction         | Texas                  |
      | acknowledge               | false                  |
      | communication methods     | Email                  |
      | delivery time             | 72 hours               |
      | not_cross_jurisdictional  | false                  |
      | jurisdictions             | <target_jurisdictions> |
      | emails                    | <target_emails>        |
    Then the following users should receive the alert email:
      | People | <recipients> |
    Then the following users should not receive any emails
      | emails | <non_recipients> |

    Scenarios:
      | target_jurisdictions          | target_emails                               | recipients                                                        | non_recipients                                                                                                                                                                                                                |
      |                               | pot.epid@example.com                        | tex.hacc@example.com, reg2.hacc@example.com, pot.hacc@example.com, pot.epid@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com                       | tex.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | tex.biot@example.com                        | tex.biot@example.com, tex.hacc@example.com | dal.hacc@example.com, dal.epid@example.com, reg2.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tar.epid@example.com, tar.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | dal.epid@example.com, tar.epid@example.com  | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com | reg2.hacc@example.com, reg1.biot@example.com, pot.hacc@example.com, pot.epid@example.com, tex.biot@example.com, reg2.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com, dal.epid@example.com | tex.hacc@example.com, dal.hacc@example.com, dal.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com | tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com, fed.hacc@example.com |
      |                               | reg1.biot@example.com, tex.biot@example.com | tex.hacc@example.com, reg1.biot@example.com, reg1.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Texas                         | tar.epid@example.com                        | tex.hacc@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Texas                         | reg1.biot@example.com                       | tex.hacc@example.com, reg1.hacc@example.com, reg1.biot@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Tarrant County                | tex.biot@example.com                        | tex.hacc@example.com, reg1.hacc@example.com, tar.epid@example.com, tar.hacc@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.biot@example.com, reg2.hacc@example.com, reg2.biot@example.com, fed.hacc@example.com |
      | Region 2                      | tex.biot@example.com                        | tex.hacc@example.com, reg2.hacc@example.com, reg2.biot@example.com, tex.biot@example.com | dal.hacc@example.com, dal.epid@example.com, tar.epid@example.com, tar.hacc@example.com, pot.hacc@example.com, pot.epid@example.com, reg1.hacc@example.com, reg1.biot@example.com, fed.hacc@example.com |
