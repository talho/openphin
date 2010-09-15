# Feature: Sending alerts to short message devices
# 
#   In order to receive alerts on a short message device
#   As an alerter
#   I want to send an alert with a short message text
# 
#   Background: 
#     Given the following users exist:
#       | John Smith      | john.smith@example.com   | Health Alert and Communications Coordinator | Dallas County  |
#       | Keith Gaddis    | keith.gaddis@example.com | Epidemiologist                              | Wise County    |
#     And the role "Health Alert and Communications Coordinator" is an alerter
#     And I am logged in as "john.smith@example.com"
#     And I am allowed to send alerts
#     When I go to the Alerts page
#     And I follow "New Alert"
#     
#   Scenario: Sending an alert with a short message to communication devices that accept short messages
#     When I fill out the alert form with:
#       | People | Keith Gaddis |
#       | Title  | H1N1 SNS push packs to be delivered tomorrow |
#       | Short Message | For more details |
#       | Communication methods | SMS |
#       
#     And I press "Preview Message"
#     Then I should see a preview of the message

#     When I press "Send"
#     Then I should see "Successfully sent the alert"
#     And I should be on the alert log
#     And "keith.gaddis@att.example.com" should receive the SMS message:
#       | body contains | For more details |
# 