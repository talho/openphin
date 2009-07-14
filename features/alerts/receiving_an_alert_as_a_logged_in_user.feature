Feature: Receiving an alert as a logged in user

  In order to ....
  As a ...
  I want to ....
  
  # the idea here was that someone who is logged in that receives an alert should be notified
  # via some AJAX update on the page. This is outside the scope of webrat although we could
  # simple make sure a JSON call to a controller properly returns new alerts and then
  # rely on manual testing to make sure its hooked up (otherwise we have to use selenium
  # which we probably want to avoid for now... wdyt?)

  Scenario: Currently logged in user receives an alert should notify them of the new alert
