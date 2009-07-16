class Delivery < ActiveRecord::Base
  belongs_to :alert
  belongs_to :user
  belongs_to :device
  
  def deliver
    device.deliver(alert)
    update_attribute :delivered_at, Time.zone.now
  end
  handle_asynchronously :deliver
end
