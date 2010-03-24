class QuerySwnForAcknowledgmentsWorker < BackgrounDRb::MetaWorker
  set_worker_name :query_swn_for_acknowledgments_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    Service::Phone::SWN::AlertNotificationResponse.active.acknowledge.each do |nresult|
      @alert = nresult.alert
      next if @alert.alert_attempts.with_device('Device::PhoneDevice').not_acknowledged.size == 0
      result = Service::Phone::SWN::NotificationResultsRequest.build(@alert.distribution_id, Service::Phone.configuration.options)
      envelope = result['soap:Envelope']
      if envelope.nil?
        PHONE_LOGGER.info "No SOAP Envelope for SWN Notification Response# #{nresult.id}"
        return false
      end
      body = envelope['soap:Body']
      if body.nil?
        PHONE_LOGGER.info "No SOAP Body for SWN Notification Response# #{nresult.id}"
        return false
      end
      response = body['getNotificationResultsResponse']
      if response.nil?
        PHONE_LOGGER.info "Body does not contain a getNotificationResultsResponse element for SWN Notification Response# #{nresult.id}"
        return false
      end
      request = response['getNotificationResultsResult']
      if request.nil?
        PHONE_LOGGER.info "Body does not contain a getNotificationResultsResult element for SWN Notification Response# #{nresult.id}"
        return false
      end
      rcptsStatus = request['rcptsStatus']
      if rcptsStatus.nil?
        PHONE_LOGGER.info "Body does not contain a rcptsStatus element for SWN Notification Response# #{nresult.id}"
        return false
      end
      rcptStatus = rcptsStatus['rcptStatus']
      if rcptStatus.nil?
        PHONE_LOGGER.info "Body does not contain a rcptStatus element for SWN Notification Response# #{nresult.id}"
      end
      rcptStatus = [rcptStatus] if rcptStatus.class == Hash
      PHONE_LOGGER.info "Processing recipient status for SWN Notification Response# #{nresult.id}"
      rcptStatus.each do |status|
        processAcknowledgmentStatus status
      end
      PHONE_LOGGER.info "Processing recipient status for SWN Notification Response# #{nresult.id} completed"
    end
  end

  def processAcknowledgmentStatus rcptStatus = nil
    return false if rcptStatus.nil? || rcptStatus['id'].blank?

    user = User.find_by_id(rcptStatus['id'])
    if user.nil?
      PHONE_LOGGER.info "Rcpt id #{rcptStatus['id']} is not a valid user"
      return false
    end

    contactPntsStatus = rcptStatus['contactPntsStatus']
    if contactPntsStatus.nil?
      PHONE_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a contactPntsStatus element"
      return false
    end

    contactPntStatus = contactPntsStatus['contactPntStatus']
    if contactPntStatus.nil?
      PHONE_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a contactPntStatus element"
    end

    contactPntStatus = [contactPntStatus] if contactPntStatus.class == Hash
    
    contactPntStatus.each do |contact|
      next if contact.nil?
      unless contact['gwbRespIndex'].blank?
        alert_attempt = @alert.alert_attempts.find_by_user_id(user.id)
        if alert_attempt.nil?
          PHONE_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a matching alert attempt for alert id #{@alert.id}"
          return false
        end
        if alert_attempt.acknowledge! "Device::PhoneDevice", contact['gwbRespIndex']
          PHONE_LOGGER.info "Rcpt id #{rcptStatus['id']} has been acknowledged"
        else
          PHONE_LOGGER.info "Could not acknowledge alert attempt #{alert_attempt.id} for Rcpt id #{rcptStatus['id']}"
        end
      end

    end
  end
end