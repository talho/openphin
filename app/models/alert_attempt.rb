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
end
