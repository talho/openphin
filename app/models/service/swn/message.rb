class Service::SWN::Message < Service::SWN::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"
  load_configuration_file RAILS_ROOT+"/config/email.yml"

  property :message


  SUPPORTED_DEVICES = {"Blackberry PIN" => Service::SWN::Blackberry::Message, "E-mail" => Service::SWN::Email::Message, "Fax" => Service::SWN::Fax::Message, "Phone" => Service::SWN::Phone::Message, "SMS" => Service::SWN::SMS::Message}

  def deliver
    raise "Service::SWN::Message: Message property is blank" if @message.blank?
    config = Service::SWN::Message.configuration
    initialize_fake_delivery(config) if config.fake_delivery?
    devices = []
    
    if message.Behavior && message.Behavior.Delivery && message.Behavior.Delivery.Providers
      if message.Behavior.Delivery.defaultProvider == "swn"
        devices = SUPPORTED_DEVICES.keys
      end

      message.Behavior.Delivery.Providers.each do |provider|
        if provider.name == "swn"
          devices |= ([provider.device] & SUPPORTED_DEVICES.keys)
        else
          devices -= [provider.device]
        end
      end
    end

    message.Recipients.each do |recipient|
      recipient.Devices.each do |device|
        if (device.provider.blank? || device.provider == "swn") && SUPPORTED_DEVICES.keys.include?(device.device_type)
          devices |= ([device.device_type] & SUPPORTED_DEVICES.keys)
        end
      end unless recipient.Devices.blank?
    end unless message.Recipients.blank?

    devices.each do |key|
      SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building message:
        |  message: #{message}
      EOT

      config = Service::SWN::Message.configuration
      body = SUPPORTED_DEVICES[key].new(:message => message,
        :username => config['username'],
        :password => config['password'],
        :retry_duration => config['retry_duration']
      ).build!

      response = perform_delivery body
      NotificationResponse.build(response, message)
    end
  end

  class NotificationResponse < ActiveRecord::Base
    set_table_name "message_notification_response"
    serialize :response

    def self.build(response, message)
      msg_id = response['soap:Envelope']['soap:Header']['wsa:MessageID'] unless response.blank? || response['soap:Envelope'].blank? || response['soap:Envelope']['soap:Header'].blank?
      self.create!(:message_id => message.messageId, :response_id => msg_id, :response => response)
    end
  end

  private

  def initialize_fake_delivery(config) # :nodoc:
    Service::SWN::Message.instance_eval do
      define_method(:perform_delivery) do |body|
        Service::SWN::Message.deliveries << OpenStruct.new(:body => body)
        config.options[:default_response] ||= "200 OK"
      end
    end
  end
end