# == Schema Information
#
# Table name: alerts
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  message                :text
#  severity               :string(255)
#  status                 :string(255)
#  acknowledge            :boolean
#  author_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  sensitive              :boolean
#  delivery_time          :integer
#  sent_at                :datetime
#  message_type           :string(255)
#  program_type           :string(255)
#  from_organization_id   :integer
#  from_organization_name :string(255)
#  from_organization_oid  :string(255)
#  identifier             :string(255)
#  scope                  :string(255)
#  category               :string(255)
#  program                :string(255)
#  urgency                :string(255)
#  certainty              :string(255)
#  jurisdictional_level   :string(255)
#

class Alert < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :from_organization, :class_name => 'Organization'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :organizations
  has_many :alert_device_types
  has_many :deliveries
  
  Statuses = ['Actual', 'Exercise', 'Test']
  Severities = ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown']
  DeliveryTimes = [15, 60, 1440, 4320]
  
  validates_inclusion_of :status, :in => Statuses
  validates_inclusion_of :severity, :in => Severities
  validates_inclusion_of :delivery_time, :in => DeliveryTimes
  
  before_create :set_message_type
  
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
    user_ids_for_delivery = jurisdictions.map(&:self_and_descendants).flatten.map(&:user_ids).flatten
    user_ids_for_delivery & roles.map(&:user_ids).flatten unless roles.empty?
    user_ids_for_delivery & organizations.map(&:user_ids).flatten unless organizations.empty?

    user_ids_for_delivery += user_ids    

    User.find(user_ids_for_delivery).each do |user|
      user.devices.select{|device| alert_device_types.map(&:device).include?(device.type) }.each do |device|      
        delivery = deliveries.create!(:user => user, :device => device)
        delivery.deliver
      end
    end
    # 2 - deliver to foreign orgs
    if jurisdictions.any?(&:root?)
      organizations.select(&:foreign).each do |foreign_org|
        foreign_org.send_later(:deliver, self)
      end
    end
  end
  
private
  def set_message_type
    self.message_type = 'Alert' if self.message_type.blank?
  end
end
