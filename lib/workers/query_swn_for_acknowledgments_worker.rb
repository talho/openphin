class QuerySwnForAcknowledgmentsWorker < BackgrounDRb::MetaWorker
  set_worker_name :query_swn_for_acknowledgments_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    Service::SWN::Alert::AlertNotificationResponse.active.acknowledge.each do |nresult|
      @alert = nresult.alert
      next if @alert.alert_attempts.with_device('Device::PhoneDevice').not_acknowledged.size == 0 && @alert.alert_attempts.with_device('Device::EmailDevice').not_acknowledged.size == 0
      result = Service::SWN::Alert::NotificationResultsRequest.build(@alert.distribution_id, Service::Phone.configuration.options)
      envelope = result['soap:Envelope']
      if envelope.nil?
        SWN_LOGGER.info "No SOAP Envelope for SWN Notification Response# #{nresult.id}"
        return false
      end
      body = envelope['soap:Body']
      if body.nil?
        SWN_LOGGER.info "No SOAP Body for SWN Notification Response# #{nresult.id}"
        return false
      end
      response = body['getNotificationResultsResponse']
      if response.nil?
        SWN_LOGGER.info "Body does not contain a getNotificationResultsResponse element for SWN Notification Response# #{nresult.id}"
        return false
      end
      request = response['getNotificationResultsResult']
      if request.nil?
        SWN_LOGGER.info "Body does not contain a getNotificationResultsResult element for SWN Notification Response# #{nresult.id}"
        return false
      end
      rcptsStatus = request['rcptsStatus']
      if rcptsStatus.nil?
        SWN_LOGGER.info "Body does not contain a rcptsStatus element for SWN Notification Response# #{nresult.id}"
        return false
      end
      rcptStatus = rcptsStatus['rcptStatus']
      if rcptStatus.nil?
        SWN_LOGGER.info "Body does not contain a rcptStatus element for SWN Notification Response# #{nresult.id}"
      end
      rcptStatus = [rcptStatus] if rcptStatus.class == Hash
      SWN_LOGGER.info "Processing recipient status for SWN Notification Response# #{nresult.id}"
      rcptStatus.each do |status|
        processAcknowledgmentStatus status
      end
      SWN_LOGGER.info "Processing recipient status for SWN Notification Response# #{nresult.id} completed"
    end
  end

  def processAcknowledgmentStatus rcptStatus = nil
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
        alert_attempt = @alert.alert_attempts.find_by_user_id(user.id)
        if alert_attempt.nil?
          SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} does not have a matching alert attempt for alert id #{@alert.id}"
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
        if alert_attempt.acknowledge! device, contact['gwbRespIndex']
          SWN_LOGGER.info "Rcpt id #{rcptStatus['id']} has been acknowledged"
        else
          SWN_LOGGER.info "Could not acknowledge alert attempt #{alert_attempt.id} for Rcpt id #{rcptStatus['id']}"
        end
        ActionController::Base.new.expire_fragment(/alert_log_entry.*#{@alert.id}.cache$/)
      end

    end
  end
end