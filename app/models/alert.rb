# == Schema Information
#
# Table name: alerts
#
#  id                           :integer         not null, primary key
#  title                        :string(255)
#  message                      :text
#  severity                     :string(255)
#  status                       :string(255)
#  acknowledge                  :boolean
#  author_id                    :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  sensitive                    :boolean
#  delivery_time                :integer
#  sent_at                      :datetime
#  message_type                 :string(255)
#  program_type                 :string(255)
#  from_organization_id         :integer
#  from_organization_name       :string(255)
#  from_organization_oid        :string(255)
#  identifier                   :string(255)
#  scope                        :string(255)
#  category                     :string(255)
#  program                      :string(255)
#  urgency                      :string(255)
#  certainty                    :string(255)
#  jurisdictional_level         :string(255)
#  references                   :string(255)
#  from_jurisdiction_id         :integer
#  original_alert_id            :integer
#  alert_acknowledged           :boolean
#  alert_acknowledged_timestamp :time
#

class Alert < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :from_organization, :class_name => 'Organization'
  belongs_to :from_jurisdiction, :class_name => 'Jurisdiction'
  belongs_to :original_alert, :class_name => 'Alert'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :organizations
  has_many :alert_device_types
  has_many :deliveries
  has_many :alert_attempts
  
  Statuses = ['Actual', 'Exercise', 'Test']
  Severities = ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown']
  MessageTypes = { :alert => "Alert", :cancel => "Cancel", :update => "Update" }
  DeliveryTimes = [15, 60, 1440, 4320]
  
  validates_inclusion_of :status, :in => Statuses
  validates_inclusion_of :severity, :in => Severities
  validates_inclusion_of :delivery_time, :in => DeliveryTimes
  
  before_create :set_message_type
  named_scope :acknowledged, :join => :alert_attempts, :conditions => "alert_attempts.acknowledged IS NOT NULL"
  
  def build_cancellation(attrs={})
    attrs = attrs.stringify_keys
    changeable_fields = ["message", "severity", "sensitive"]
    overwrite_attrs = attrs.slice(*changeable_fields)
    self.class.new attrs.merge(self.attributes).merge(overwrite_attrs) do |alert|
      alert.title = "[Cancel] - #{title}"
      alert.message_type = MessageTypes[:cancel]
      alert.original_alert = self
    end
  end
  
  def after_initialize
    self.acknowledge = true if acknowledge.nil?
  end
  
  def device_types=(types)
    alert_device_types.clear
    types.each do |type|
      alert_device_types.build :device => type
    end
  end
  
  def device_types
    alert_device_types.map(&:device)
  end
  
  def human_delivery_time
    self.class.human_delivery_time(delivery_time)
  end
  
  def self.human_delivery_time(minutes)
    minutes > 60 ? "#{minutes/60} hours" : "#{minutes} minutes"    
  end
  
  def deliver
    # 1 - explode all known users and deliver to them
    find_user_recipients.each do |user|
      user.devices.all(:conditions => {:type => device_types}).each do |device|      
        deliveries.create!(:user => user, :device => device).deliver
      end
    end
    # 2 - deliver to foreign orgs
    if jurisdictions.any?(&:root?)
      organizations.select(&:foreign).each do |organization|
        deliveries.create!(:organization => organization).deliver
      end
    end
  end
  handle_asynchronously :deliver
  
  def acknowledgments
    alert_attempts.all(:conditions => "acknowledged_at IS NOT NULL")
  end
  
  def acknowledged_percent
    if(alert_attempts.size > 0)
      total = alert_attempts.size.to_f
      acked = alert_attempts.acknowledged.size.to_f
      (acked/total*100)
    else
      0
    end
  end

  
private
  def set_message_type
    self.message_type = MessageTypes[:alert] if self.message_type.blank?
  end
  
  def find_user_recipients
    user_ids_for_delivery = jurisdictions.map(&:self_and_descendants).flatten.map(&:user_ids).flatten
    user_ids_for_delivery &= roles.map(&:user_ids).flatten unless roles.empty?
    user_ids_for_delivery &= organizations.map(&:user_ids).flatten unless organizations.empty?

    user_ids_for_delivery += user_ids    

    User.find(user_ids_for_delivery)
  end
end
