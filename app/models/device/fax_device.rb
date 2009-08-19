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

class Device::FaxDevice < Device
  
  option_accessor :fax
  
  def self.display_name
    'Fax'
  end
  
  def deliver(alert)
    Service::Fax.deliver_alert(alert, user)
  end
  
  def self.batch_deliver(alert)
    Service::Fax.batch_deliver_alert(alert)
  end
end
