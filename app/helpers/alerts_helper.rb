module AlertsHelper
  
  def acknowledge_alert_button(alert)
    if alert.ask_for_acknowledgement?
      button_to 'Acknowledge', acknowledge_alert_path(alert), :method => :put
    end
  end
end
