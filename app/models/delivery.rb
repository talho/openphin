# == Schema Information
#
# Table name: deliveries
#
#  id              :integer         not null, primary key
#  alert_id        :integer
#  device_id       :integer
#  user_id         :integer
#  delivered_at    :datetime
#  acknowledged_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#

class Delivery < ActiveRecord::Base
  belongs_to :alert
  belongs_to :user
  belongs_to :device
  belongs_to :organization
  
  def deliver
    if organization.nil?
      device.deliver(alert)
    else
      organization.deliver(alert)
    end
    update_attribute :delivered_at, Time.zone.now
  end
  handle_asynchronously :deliver
end
