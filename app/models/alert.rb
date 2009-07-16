# == Schema Information
#
# Table name: alerts
#
#  id            :integer         not null, primary key
#  title         :string(255)
#  message       :text
#  severity      :string(255)
#  status        :string(255)
#  acknowledge   :boolean
#  author_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  sensitive     :boolean
#  delivery_time :integer
#  sent_at       :datetime
#  message_type  :string(255)
#  program_type  :string(255)
#

class Alert < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :organizations
  has_many :alert_device_types
  
  Statuses = ['Actual', 'Exercise', 'Test']
  Severities = ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown']
  DeliveryTimes = [15, 60, 1440, 4320]
  
  validates_inclusion_of :status, :in => Statuses
  validates_inclusion_of :severity, :in => Severities
  validates_inclusion_of :delivery_time, :in => DeliveryTimes
  
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
    # 2 - deliver to foreign orgs
    organizations.select(&:foreign).each do |foreign_org|
      foreign_org.send_later(:deliver, self)
    end
  end
  
end
