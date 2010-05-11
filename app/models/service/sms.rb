require 'nokogiri'

class Service::SMS < Service::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"

  def self.deliver_alert(alert, user, config=Service::SMS.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = SWN.new(alert, config, [user])
    Service::SWN::Alert::AlertNotificationResponse.build(response,alert)
  end

  def self.batch_deliver_alert(alert, config=Service::SMS.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    users = alert.alert_attempts.with_device("Device::SMSDevice").map{ |aa| aa.user }
    response = Service::SWN::Alert.new(alert, config, users, "Service::SWN::SMS::Alert").deliver  
    Service::SWN::Alert::AlertNotificationResponse.build(response,alert)
  end

  class << self
    private
    
    # Overwrites SWN.deliver to push message onto
    # Service::Phone.deliveries.
    def initialize_fake_delivery(config) # :nodoc:
      Service::SWN::Alert.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::SMS.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end 
end
