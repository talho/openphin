# == Schema Information
#
# Table name: devices
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)
#  type          :string(255)
#  description   :string(255)
#  name          :string(255)
#  coverage      :string(255)
#  emergency_use :boolean(1)
#  home_use      :boolean(1)
#  options       :text
#

class Device::SMSDevice < Device
  
  option_accessor :sms
  
  def self.display_name
    'SMS'
  end
  
  def deliver(alert)
    Service::SMS.deliver_alert(alert, user, self)
  end
  
  def batch_deliver(alert)
    Service::SMS.batch_deliver_alert(alert, self)
  end
end
