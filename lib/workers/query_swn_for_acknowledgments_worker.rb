class QuerySwnForAcknowledgmentsWorker < BackgrounDRb::MetaWorker
  set_worker_name :query_swn_for_acknowledgments_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    Service::Phone::SWN::NotificationResponse.active.acknowledge.each do |nresult|
      result = Service::Phone::SWN::NotificationResultsRequest.build(nresult, Service::Phone.configuration.options)
      
    end
  end
end

