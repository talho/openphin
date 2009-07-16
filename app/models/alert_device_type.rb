# == Schema Information
#
# Table name: alert_device_types
#
#  id         :integer         not null, primary key
#  alert_id   :integer
#  device     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AlertDeviceType < ActiveRecord::Base
end
