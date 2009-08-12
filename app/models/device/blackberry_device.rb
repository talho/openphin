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

class Device::BlackberryDevice < Device
  
  option_accessor :blackberry
  
  def self.display_name
    'Blackberry'
  end
  
  def deliver(alert)
  end
  
  def batch_deliver(alert)
  end
end
