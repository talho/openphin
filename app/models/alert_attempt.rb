# == Schema Information
#
# Table name: alert_attempts
#
#  id                                :integer(4)      not null, primary key
#  alert_id                          :integer(4)
#  user_id                           :integer(4)
#  requested_at                      :datetime
#  acknowledged_at                   :datetime
#  created_at                        :datetime
#  updated_at                        :datetime
#  organization_id                   :integer(4)
#  token                             :string(255)
#  jurisdiction_id                   :integer(4)
#  acknowledged_alert_device_type_id :integer(4)
#  call_down_response                :integer(4)
#

class AlertAttempt < ActiveRecord::Base
  belongs_to :alert
  belongs_to :user, :include => [:devices, :role_memberships]
  belongs_to :organization
  belongs_to :jurisdiction
  belongs_to :acknowledged_alert_device_type, :foreign_key => :acknowledged_alert_device_type_id, :class_name => "AlertDeviceType"
  has_many :deliveries, :dependent => :delete_all
  has_many :devices, :through => :deliveries, :uniq => true

  named_scope :acknowledged, :conditions => "acknowledged_at IS NOT NULL"
  named_scope :not_acknowledged, :conditions => "acknowledged_at IS NULL"
  named_scope :with_device, lambda {|device_type|
    if device_type.is_a?(AlertDeviceType)
      d=device_type.device
    elsif device_type.is_a?(Device)
      d=device_type.class.name
    else
      d=device_type
    end

    {:include => [:jurisdiction, :organization, :alert, :user, :acknowledged_alert_device_type, :devices],
     :conditions => ["devices.type = ?", d]}}
  named_scope :acknowledged_by_device, lambda {|device_type|
    if device_type.is_a?(AlertDeviceType)
        d=device_type.device
      elsif device_type.is_a?(Device)
        d=device_type.class.name
      else
        d=device_type
      end

      {:include => :acknowledged_alert_device_type,
       :conditions => ["alert_device_types.device = ?", d]}}
     
  before_save :generate_acknowledgment_token
     
  def deliver
    if jurisdiction.nil? && organization.nil?
      user.devices.all(:conditions => {:type => alert.device_types}).each do |device|
        deliveries.create!(:device => device).deliver
      end
    elsif jurisdiction.nil?
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      organization.deliver(alert)
    else
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      jurisdiction.deliver(alert)
    end
  end
  
  def batch_deliver
    if jurisdiction.nil? && organization.nil?
      user.devices.all(:conditions => {:type => alert.device_types}).each do |device|
        deliveries.create!(:device => device)
      end
    elsif jurisdiction.nil?
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      organization.deliver(alert)
    else
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      jurisdiction.deliver(alert)
    end
  end
  
  def acknowledged?
    acknowledged_at || false
  end
  
  def acknowledge! alert_device_type = nil, response = 0
    if alert.has_alert_response_messages?
      if response == 0 || response == ""
        errors.add('acknowledgement','You must select a response before acknowledging this alert.')  
        return
      end
    end
    unless self.acknowledged?
      device = alert_device_type || "Device::ConsoleDevice"
      find_by_device = alert_device_type.nil? ? "Device::ConsoleDevice" : alert_device_type
      update_attributes( 
        :acknowledged_alert_device_type_id => AlertDeviceType.find_by_alert_id_and_device(alert.id, find_by_device ).id,
        :acknowledged_at => Time.zone.now,
        :call_down_response => response.to_i)
      alert.update_statistics(:device => device, :jurisdiction => user.jurisdictions, :response => response)
    end
  end

  def as_json(options = {})
    options[:include] = {} if options[:include].nil?
    include = {:user => {:only => [:display_name, :email]}}
    include[:acknowledged_alert_device_type] = {} unless acknowledged_alert_device_type_id.nil?
    options[:include].merge! include
    super(options)
  end

  protected
  def generate_acknowledgment_token
    self.token = ActiveSupport::SecureRandom.hex
  end
end
