class QuerySwnForAcknowledgmentsWorker < BackgrounDRb::MetaWorker
  set_worker_name :query_swn_for_acknowledgments_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    result = ''
    if Rails.env == 'cucumber'
      result = Crack::XML.parse(File.read("#{args[:filename]}"))
      alert = Alert.find_by_id(1) # in testing, we should always be looking for alert 1
    else
      Service::SWN::Alert::AlertNotificationResponse.active.acknowledge.map(&:alert).uniq.each do |alert|
        next if alert.alert_attempts.with_device('Device::PhoneDevice').not_acknowledged.size == 0 && alert.alert_attempts.with_device('Device::EmailDevice').not_acknowledged.size == 0
        devices = {"Device::PhoneDevice" => "PHONE", "Device::EmailDevice" => "EMAIL"}
        alert.alert_device_types.map(&:device).reject{|type| devices[type].blank?}.each do |type|
          result = Service::SWN::Alert::NotificationResultsRequest.build("#{alert.distribution_id}-#{devices[type]}", Service::Phone.configuration.options)
        end
      end
    end
    envelope = result['soap:Envelope']

    if envelope.nil?
      SWN_LOGGER.info "No SOAP Envelope for SWN Notification Response with alert # #{alert.id}"
      return false
    end
    body = envelope['soap:Body']
    if body.nil?
      SWN_LOGGER.info "No SOAP Body for SWN Notification Response with alert # #{alert.id}"
      return false
    end
    response = body['getNotificationResultsResponse']
    if response.nil?
      SWN_LOGGER.info "Body does not contain a getNotificationResultsResponse element for SWN Notification Response with alert # #{alert.id}"
      return false
    end
    request = response['getNotificationResultsResult']
    if request.nil?
      SWN_LOGGER.info "Body does not contain a getNotificationResultsResult element for SWN Notification Response with alert # #{alert.id}"
      return false
    end
      # A bit of a hack to work around the lack of UTC offset information in SWN's acknowledgement data.
      # The offset *is* provided in the timestamp for the xml file generation, and can be correctly applied to the acknowledgement time ==most of the time==
      # There will always be unavoidable edge cases in the minutes surrounding the Daylight Savings Time switch, and this is unavoidable until SWN includes an offset in the timestamp
      # Because this method  two of SWN's own timestamps, local time differences are not important.  The resulting offset is relative to UTC
      # I chose this process over native timezone methods because both ruby and rails seem to be changing the behavior with each release.
    request['resultGeneratedTimestamp'] =~ /([+-])(\d\d):\d\d$/
    time_offset_seconds = ($2.to_i * 3600)
    time_offset = $1 == '-' ? time_offset_seconds : time_offset_seconds *= -1  # negative or positive?

    rcptsStatus = request['rcptsStatus']
    if rcptsStatus.nil?
      SWN_LOGGER.info "Body does not contain a rcptsStatus element for SWN Notification Response with alert # #{alert.id}"
      return false
    end
    rcptStatus = rcptsStatus['rcptStatus']
    if rcptStatus.nil?
      SWN_LOGGER.info "Body does not contain a rcptStatus element for SWN Notification Response with alert # #{alert.id}"
    end
    rcptStatus = [rcptStatus] if rcptStatus.class == Hash
    SWN_LOGGER.info "Processing recipient status for SWN Notification Response with alert # #{alert.id}"
    rcptStatus.each do |status|
      processAcknowledgmentStatus alert, status, time_offset
    end
    SWN_LOGGER.info "Processing recipient status for SWN Notification Response with alert # #{alert.id} completed"
  end

  def processAcknowledgmentStatus alert, rcptStatus = nil, time_offset = 0
    return false if rcptStatus.nil? || rcptStatus['id'].blank?

    user = User.find_by_id(rcptStatus['id'])
    if user.nil?
      SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} is not a valid user"
      return false
    end

    contactPntsStatus = rcptStatus['contactPntsStatus']
    if contactPntsStatus.nil?
      SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a contactPntsStatus element"
      return false
    end

    contactPntStatus = contactPntsStatus['contactPntStatus']
    if contactPntStatus.nil?
      SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a contactPntStatus element"
    end

    contactPntStatus = [contactPntStatus] if contactPntStatus.class == Hash

    contactPntStatus.each do |contact|
      next if contact.nil?
      unless contact['gwbRespIndex'].blank?
        alert_attempt = alert.alert_attempts.find_by_user_id(user.id)
        if alert_attempt.nil?
          SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a matching alert attempt for alert id #{alert.id}"
          return false
        end
        device = ""
        case contact['type']
          when "Email"
            device = "Device::EmailDevice"
          when "Phone", "Voice"
            device = "Device::PhoneDevice"
          else
            next
        end
        unless alert_attempt.acknowledged?
          ack_time = contact['deliveryTimestamp'].to_time + time_offset
          if alert_attempt.acknowledge! :ack_device => device, :ack_response => contact['gwbRespIndex'], :ack_time => ack_time
            SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} has been acknowledged"
          else
            SWN_LOGGER.info "Could not acknowledge alert attempt #{alert_attempt.id} for Rcpt id #{rcptStatus['id']}"
          end
          ActionController::Base.new.expire_fragment(/alert_log_entry.*#{alert.id}.cache$/)
        end
      end

    end
  end
end