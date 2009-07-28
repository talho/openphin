# == Schema Information
#
# Table name: alert_attempts
#
#  id              :integer         not null, primary key
#  alert_id        :integer
#  user_id         :integer
#  requested_at    :datetime
#  acknowledged_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#

class AlertAttempt < ActiveRecord::Base
  belongs_to :alert
  belongs_to :user
  belongs_to :organization
  has_many :deliveries
  has_many :devices, :through => :deliveries, :uniq => true

  named_scope :acknowledged, :conditions => "acknowledged_at IS NOT NULL"
  named_scope :with_device, lambda {|device_type|
    if device_type.is_a?(Class)
      d=device_type.name
    elsif device_type.is_a?(Device)
      d=device_type.class.name
    else
      d=device_type
    end

    {:include => :devices,
     :conditions => ["devices.type = ?", d]}}
     
   #validates_uniqueness_of :user, :scope => :alert
   #validates_uniqueness_of :organization, :scope => :alert
     
  before_save :generate_acknowledgment_token
     
  def deliver
    if organization.blank?
      user.devices.all(:conditions => {:type => alert.device_types}).each do |device|
        deliveries.create!(:device => device).deliver
      end
    else
      deliveries.create!
      organization.deliver(alert)
    end
  end
  
  def acknowledge!
    update_attribute(:acknowledged_at, Time.zone.now)
  end
  
  protected
  def generate_acknowledgment_token
    self.token = ActiveSupport::SecureRandom.hex
  end
end
