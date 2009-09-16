class QueryTfccForAcknowledgmentsWorker < BackgrounDRb::MetaWorker
  set_worker_name :query_tfcc_for_acknowledgments_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    Service::Phone::TFCC::CampaignActivationResponse.active.acknowledge.each do |car|
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
            alert_attempt = car.alert.alert_attempts.with_device("Device::PhoneDevice").find_by_user_id(user.id) unless user.blank?
            if(!alert_attempt.blank?)
              alert_attempt.acknowledged_at = time
              alert_attempt.acknowledged_device_type = AlertDeviceType.find_by_device("Device::PhoneDevice")
              alert_attempt.save!
            end
          end
         end
      end
    end
  end
end

