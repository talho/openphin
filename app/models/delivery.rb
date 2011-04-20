# == Schema Information
#
# Table name: deliveries
#
#  id                  :integer(4)      not null, primary key
#  device_id           :integer(4)
#  delivered_at        :datetime
#  sys_acknowledged_at :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  alert_attempt_id    :integer(4)
#

class Delivery < ActiveRecord::Base
  belongs_to :alert_attempt
  has_one :user, :through => :alert_attempt
  belongs_to :device
  has_one :alert, :foreign_key => :alert_id, :through => :alert_attempt
  has_one :organization, :through => :alert_attempt
  has_one :jurisdiction, :through => :alert_attempt
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

#  default_scope :order => "delivered_at DESC"

  named_scope :sys_acknowledged?, :conditions => "sys_acknowledged_at IS NOT NULL"
  named_scope :delivered, :conditions => "delivered_at IS NOT NULL"
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

  def delivered?
    delivered_at.nil?
  end
  
  def deliver
    if jurisdiction.nil? && organization.nil?
      device.deliver(alert)
    elsif jurisdiction.nil?
      organization.deliver(alert)
    else
      jurisdiction.deliver(alert)
    end
    update_attribute :delivered_at, Time.zone.now
  end
  #handle_asynchronously :deliver

  def to_s
    begin att = AlertAttempt.find(alert_attempt_id).to_s rescue att = '-?-' end
    begin dev = Device.find(device_id).to_s rescue dev = '-?-' end
    dev + ', ' + att
  end
end
