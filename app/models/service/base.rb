class Service::Base

  # Configuration is used to configure services. It should
  # be configured through a block. For example:
  #   Service::Sms.configure do |config|
  #     config.delivery_method = :deliver
  #   end
  #
  # You can also configure arbitrary options that a service supports
  # by storing them in the options hash. For example:
  #   Service::Sms.configure do |config|
  #     config.options[:sms_config] = YAML.load("sms_config.yml")
  #   end
  #
  # The two possible delivery options are :test and :deliver. The
  # :test delivery method should be used in the 'test' and 'cucumber'
  # environments. It will add a #deliveries method to the service
  # in which you can verify that messages are being delivered.
  # For example:
  #   Service::Sms.configure do |config|
  #     config.delivery_method = :test
  #   end
  #   
  #   # in test after a delivery is performed
  #   Service::Sms.deliveries # => array of delivered messages
  # 
  # The default delivery method is +deliver+
  PROVIDERS = {:swn => Service::SWN::Message, :talho => Service::TALHO::Message}


  def self.dispatch message
    providers = []
    if message.Behavior && message.Behavior.Delivery
      providers = message.Behavior.Delivery.Providers.map(&:name).map(&:to_sym).uniq
      providers << message.Behavior.Delivery.defaultProvider.to_sym unless message.Behavior.Delivery.defaultProvider.blank?
    end
    providers = [:swn] if providers.blank?
    
    providers.each do |provider|
      if PROVIDERS[provider]
        provider_message = PROVIDERS[provider].new(:message => message)
        provider_message.deliver
      else
        LOGGER.warn = "#{provider} is not a valid service provider"
      end
    end
  end
end