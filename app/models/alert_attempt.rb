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
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :acknowledged, :conditions => "acknowledged_at IS NOT NULL"
  scope :not_acknowledged, :conditions => "acknowledged_at IS NULL"
  scope :with_device, lambda {|device_type|
    if device_type.is_a?(AlertDeviceType)
      d=device_type.device
    elsif device_type.is_a?(Device)
      d=device_type.class.name
    else
      d=device_type
    end

    {:include => [:jurisdiction, :organization, :user, :acknowledged_alert_device_type, :devices],
     :conditions => ["devices.type = ?", d]}}
  scope :acknowledged_by_device, lambda {|device_type|
    if device_type.is_a?(AlertDeviceType)
        d=device_type.device
      elsif device_type.is_a?(Device)
        d=device_type.class.name
      else
        d=device_type
      end

      {:include => :acknowledged_alert_device_type,
       :conditions => ["alert_device_types.device = ?", d]}}

  after_create :update_alert_type
  before_create :generate_acknowledgment_token

  def deliver
    if jurisdiction.nil? && organization.nil?
      user.devices.all(:conditions => {:type => alert.device_types}).each do |device|
        deliveries.create!(:device => device).deliver
      end
    elsif jurisdiction.nil?
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      Organization.deliver(alert)
    else
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      Jurisdiction.deliver(alert)
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
      Organization.deliver(alert)
    else
      deliveries.create!
      alert.sent_at = Time.zone.now
      alert.save
      Jurisdiction.deliver(alert)
    end
  end
  
  def acknowledged?
    acknowledged_at || false
  end

  def acknowledge!(options = {})
    if acknowledged_at.nil?
      response = options[:call_down_response] = options.delete(:response)
      return false unless response.present?
      options[:acknowledged_at] = options[:acknowledged_at] || Time.zone.now
      device = options.delete(:device) || "Device::ConsoleDevice"
      options[:acknowledged_alert_device_type_id] = AlertDeviceType.find_by_alert_id_and_device(alert.id, device).id
      if ( status = update_attributes(options) )
        alert.update_statistics(:device => device, :jurisdiction => user.jurisdictions, :response => response)
      end
      status
    elsif alert.expired?
      raise "This Alert has expired and can no longer be acknowledged."
    else
      raise "You may have already acknowledged the alert."
    end
  end

  def as_json(options = {})
    options = {} if options.blank?
    options[:include] = {} if options[:include].nil?
    include = {:user => {:only => [:display_name, :email]}}
    include[:acknowledged_alert_device_type] = {} unless acknowledged_alert_device_type_id.nil?
    options[:include].merge! include
    super(options)
  end

  def to_s
    begin recip = User.find(user_id).to_s rescue recip = '-?-' end
    begin alert = Alert.find(alert_id).to_s rescue alert = '-?-' end
    alert + ' to ' + recip
  end

  protected

  def generate_acknowledgment_token
    self.token = SecureRandom.hex
  end

  private

  def update_alert_type
    update_attribute('alert_type', alert.class.to_s)
  end
end
