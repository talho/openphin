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

class Device::ImDevice < Device

  option_accessor :im

  def self.display_name
    'Instant Messaging'
  end

  def to_s
    super + ": #{im}"
  end

  def key
    :im
  end
end
