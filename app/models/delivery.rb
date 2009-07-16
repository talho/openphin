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
