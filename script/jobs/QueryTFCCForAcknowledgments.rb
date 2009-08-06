Service::Phone::TFCC::CampaignActivationResponse.find_by_sql("SELECT DISTINCT c.* FROM tfcc_campaign_activation_response AS c, alerts as a, alert_attempts as aa, deliveries as de, devices AS d WHERE c.alert_id=a.id AND aa.alert_id=a.id AND de.alert_attempt_id=aa.id AND de.device_id=d.id AND d.type='Device::PhoneDevice' AND aa.acknowledged_at IS NULL").each do |car|
  result = Service::Phone::TFCC::DetailedActivationResults.build(car, Service::Phone.configuration.options)
  detail = result['ucsxml']['response']['activation_detail']
  results_returned = detail['results_returned']

  if results_returned != "0"
    detail['results'].each do |result|
      email = result[1]['c0']
      response = result[1]['data1']
      time = result[1]['xdate']
      
      if response == "1" && !email.blank?
        user = User.find_by_email(email)
        alert_attempt = car.phone_alert_attempts.find_by_user_id(user.id) unless user.blank?
        if(!alert_attempt.blank?)
          puts "Yep!"
          alert_attempt.acknowledged_at = time
          alert_attempt.save!
        end
      end
    end
  end
end