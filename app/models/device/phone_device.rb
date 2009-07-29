class Device::PhoneDevice < Device
  
  serialize :options
  option_accessor :phone
  
  # validates_presence_of     :email_address
  # validates_format_of       :email_address, :with => %r{.+@.+\..+}
  
  def self.display_name
    'Phone'
  end
  
  def deliver(alert)
    Service::Phone.deliver_alert(alert, user, self)
  end
end
