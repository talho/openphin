# == Schema Information
#
# Table name: alert_device_types
#
#  id         :integer(4)      not null, primary key
#  alert_id   :integer(4)
#  device     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AlertDeviceType < ActiveRecord::Base
  belongs_to :alert

  def device_type
    self.device.constantize
  end

  def to_s
    device_type.demodulize
  end
end
