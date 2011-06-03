class Service::TALHO::Message < Service::TALHO::Base

  property :message
  
  SUPPORTED_DEVICES = {"E-mail" => Service::TALHO::Email::Message}

  def deliver
    # Need to find the messages that are being sent via a supported device
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
  
end