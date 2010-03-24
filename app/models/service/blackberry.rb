require 'nokogiri'

class Service::Blackberry < Service::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"

  def self.deliver_alert(alert, config=Service::Blackberry.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = SWN.new(alert, config, [user])
    SWN::AlertNotificationResponse.build(response,alert)
  end

    
  def self.batch_deliver_alert(alert, config=Service::Blackberry.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    users = alert.alert_attempts.with_device("Device::BlackberryDevice").map{ |aa| aa.user }
    response = SWN.new(alert, config, users).batch_deliver
    SWN::AlertNotificationResponse.build(response,alert)
  end

  class << self
    private
    
    # Overwrites SWN.deliver to push message onto 
    # Service::Blackberry.deliveries.
    def initialize_fake_delivery(config) # :nodoc:
      SWN.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Blackberry.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end
  
  class SWN < Service::SWN::Base
    def initialize(alert, config, users)
      @alert, @config, @users = alert, config, users
    end

    def perform_delivery(body)
      Dialer.new(@config['url'], @config['username'], @config['password']).deliver(body)
    end

    class AlertNotificationResponse < ActiveRecord::Base
      set_table_name "swn_notification_response"
      belongs_to :alert

      def self.build(response, alert)
        if !alert.blank?
          if !response.blank? && !response['soap:Envelope'].blank? && !response['soap:Envelope']['soap:Header'].blank?
            msg_id = response['soap:Envelope']['soap:Header']['wsa:MessageID']
            self.create!(:alert => alert, :message_id => msg_id)
          else
            self.create!(:alert => alert)
          end
        end
      end
    end

    def deliver
      SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building alert message:
        |  alert: #{@alert.id}
        |  user_ids: #{@users.map(&:id).inspect}
        |  config: #{@config.options.inspect}
      EOT
      
      body = Service::SWN::Blackberry::Alert.new(
        :alert => @alert, 
        :users => @users,
        :username => @config['username'],
        :password => @config['password'],
        :retry_duration => @config['retry_duration']
      ).build!

      perform_delivery body
    end
    
    def batch_deliver
     SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building alert message:
        |  alert: #{@alert.id}
        |  config: #{@config.options.inspect}
      EOT
      
      body = Service::SWN::Blackberry::Alert.new(
        :alert => @alert, 
        :users => @users, 
        :username => @config['username'],
        :password => @config["password"],
        :retry_duration => @config['retry_duration']
      ).build!

      perform_delivery body
    end

  end
  
end
