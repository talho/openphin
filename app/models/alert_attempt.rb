# == Schema Information
#
# Table name: alert_attempts
#
#  id              :integer         not null, primary key
#  alert_id        :integer
#  user_id         :integer
#  device_id       :integer
#  requested_at    :datetime
#  acknowledged_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class AlertAttempt < ActiveRecord::Base
  belongs_to :alert
  belongs_to :user
  belongs_to :device

  named_scope :acknowledged, :conditions => "acknowledged_at IS NOT NULL"
  named_scope :with_device, lambda {|device_type|
	  if device_type.is_a?(Class)
		  d=device_type.name
	  elsif device_type.is_a?(Device)
		  d=device_type.class.name
	  else
		  d=device_type
	  end

	  {:include => "device",
	   :conditions => ["devices.type = ?", d]}}
end
