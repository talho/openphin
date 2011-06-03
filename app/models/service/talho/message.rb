class Service::TALHO::Message < Service::TALHO::Base
  load_configuration_file RAILS_ROOT+"/config/talho_service.yml"
  load_configuration_file RAILS_ROOT+"/config/email.yml"
  
  property :message
  
  SUPPORTED_DEVICES = {"E-mail" => Service::TALHO::Email::Message}

  def deliver
    # Need to find the messages that are being sent via a supported device
    raise "Service::TALHO::Message: Message property is blank" if @message.blank?
    config = Service::TALHO::Message.configuration
    initialize_fake_delivery(config) if config.fake_delivery?
    devices = []
    
    if message.Behavior && message.Behavior.Delivery && message.Behavior.Delivery.Providers
      message.Behavior.Delivery.Providers.select {|p| p.name == 'talho'}.each do |provider|
        devices |= ([provider.device] & SUPPORTED_DEVICES.keys)
      end
    end
    
    devices.each do |device|
      msg = SUPPORTED_DEVICES[device].new :message => message
      msg.perform_delivery
    end
  end
  
  def self.deliver message
    talho_msg = Service::TALHO::Message.new :message => message
    talho_msg.deliver
  end
  
  private
  
  def initialize_fake_delivery(config) # :nodoc:
    SUPPORTED_DEVICES[device].each do |device|
      device.instance_eval do
        define_method(:perform_delivery) do
          Service::TALHO::Message.deliveries << OpenStruct.new(:message => message)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end
end