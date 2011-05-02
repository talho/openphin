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
  belongs_to :alert, :polymorphic => true
  belongs_to :user, :include => [:devices, :role_memberships]
  belongs_to :organization
  belongs_to :jurisdiction
  belongs_to :acknowledged_alert_device_type, :foreign_key => :acknowledged_alert_device_type_id, :class_name => "AlertDeviceType"
  has_many :deliveries, :dependent => :delete_all
  has_many :devices, :through => :deliveries, :uniq => true
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

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

    {:include => [:jurisdiction, :organization, :user, :acknowledged_alert_device_type, :devices],
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

  after_create :update_alert_type
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
  
  def acknowledge! options = {} # accepted options: ack_device, ack_response, ack_time
    unless self.acknowledged?
      unless alert.expired?
        if alert.acknowledge?
          #TODO: narrow range of allowed responses to the number on that alert
          if !(1..5).include? options[:ack_response].to_i || options[:ack_response].blank?
            errors.add('acknowledgement','You must select a response before acknowledging this alert.')
            return
          else
            ack_response = options[:ack_response]
          end
        end
        ack_device = options[:ack_device].blank? ? "Device::ConsoleDevice" : options[:ack_device]
        ack_time = options[:ack_time].blank? ? Time.zone.now : options[:ack_time]
        update_attributes(
          :acknowledged_alert_device_type_id => AlertDeviceType.find_by_alert_id_and_device(alert.id, ack_device ).id,
          :acknowledged_at => ack_time,
          :call_down_response => ack_response.to_i)
        alert.update_statistics(:device => ack_device, :jurisdiction => user.jurisdictions, :response => ack_response)
      else
        errors.add("acknowledgement", "This Alert has expired and can no longer be acknowledged.")
      end
    else
      errors.add("acknowledgement", "This Alert was previously acknowledged.  Please check the Alert for details.")
    end
  end

  def as_json(options = {})
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
    self.token = ActiveSupport::SecureRandom.hex
  end

  private
  def update_alert_type
    update_attribute('alert_type', alert.class.to_s)
  end
end
