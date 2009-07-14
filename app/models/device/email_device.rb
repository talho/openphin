# == Schema Information
#
# Table name: devices
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  type          :string(255)
#  description   :string(255)
#  name          :string(255)
#  coverage      :string(255)
#  emergency_use :boolean
#  home_use      :boolean
#

class Device::EmailDevice < Device
  
  serialize :options
  option_accessor :email_address
  
  def self.display_name
    'E-mail'
  end
end
