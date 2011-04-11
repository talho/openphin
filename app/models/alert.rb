# == Schema Information
#
# Table name: alerts
#
#  id                             :integer(4)      not null, primary key
#  title                          :string(255)
#  message                        :text
#  severity                       :string(255)
#  status                         :string(255)
#  acknowledge                    :boolean(1)
#  author_id                      :integer(4)
#  created_at                     :datetime
#  updated_at                     :datetime
#  sensitive                      :boolean(1)
#  delivery_time                  :integer(4)
#  sent_at                        :datetime
#  message_type                   :string(255)
#  program_type                   :string(255)
#  from_organization_id           :integer(4)
#  from_organization_name         :string(255)
#  from_organization_oid          :string(255)
#  identifier                     :string(255)
#  scope                          :string(255)
#  category                       :string(255)
#  program                        :string(255)
#  urgency                        :string(255)
#  certainty                      :string(255)
#  jurisdiction_level             :string(255)
#  references                     :string(255)
#  from_jurisdiction_id           :integer(4)
#  original_alert_id              :integer(4)
#  short_message                  :string(255)     default("")
#  message_recording_file_name    :string(255)
#  message_recording_content_type :string(255)
#  message_recording_file_size    :integer(4)
#  distribution_reference         :string(255)
#  caller_id                      :string(255)
#  ack_distribution_reference     :string(255)
#  distribution_id                :string(255)
#  reference                      :string(255)
#  sender_id                      :string(255)
#  call_down_messages      n       :text
#  not_cross_jurisdictional       :boolean(1)     default(true)
#

require 'ftools'

class Alert < ActiveRecord::Base
  acts_as_MTI

  belongs_to :author, :class_name => 'User'

  has_many :targets, :as => :item, :foreign_key => :item_id, :conditions => 'targets.item_type = \'#{self.class.to_s}\'', :include => :users
  has_many :audiences, :through => :targets, :include => [:roles, :jurisdictions, :users]

  has_many :alert_device_types, :foreign_key => :alert_id, :dependent => :delete_all
  has_many :alert_attempts, :foreign_key => :alert_id, :dependent => :destroy, :include => [:user, :acknowledged_alert_device_type, :jurisdiction, :organization, :devices], :as => :alert
  has_many :deliveries, :through => :alert_attempts
  has_many :attempted_users, :through => :alert_attempts, :source => :user, :uniq => true
  has_many :acknowledged_users,
           :source => :user,
           :through => :alert_attempts,
           :uniq => true,
           :conditions => ["alert_attempts.acknowledged_at IS NOT NULL"]
  has_many :unacknowledged_users,
           :source => :user,
           :through => :alert_attempts,
           :uniq => true,
           :conditions => ["alert_attempts.acknowledged_at IS NULL"]

  has_many :ack_logs, :class_name => 'AlertAckLog'
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'Alert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  after_create :create_console_alert_device_type

  named_scope :acknowledged, :join => :alert_attempts, :conditions => "alert_attempts.acknowledged IS NOT NULL"
  named_scope :devices, {
      :select => "DISTINCT devices.type",
      :joins => "INNER JOIN alert_attempts ON alerts.id=alert_attempts.alert_id INNER JOIN deliveries ON deliveries.alert_attempt_id=alert_attempts.id INNER JOIN devices ON deliveries.device_id=devices.id",
      :conditions => "alerts.id=#{object_id}"
  }
  named_scope :has_acknowledge, :conditions => ['acknowledge = ?', true]

  def self.default_alert
    title = "Example Alert - please click More to see the alert contents"
    message = "This is an example of ah alert.  You can see the title above and this is the alert body.\n\nThe status lets you know if this is an actual alert or just a test alert."
    Alert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end

#  def superclass
#    self.class.superclass
#  end

  def audiences_attributes=(attrs={})
    attrs.each do |key, value|
      audiences << Audience.new(value)
    end
  end

  def device_types=(types)
    alert_device_types.clear
    types.each do |type|
      alert_device_types.build :device => type
    end unless types.nil?
  end

  def device_types
    alert_device_types.map(&:device)
  end

  def acknowledgments
    alert_attempts.all(:conditions => "acknowledged_at IS NOT NULL")
  end

  def acknowledged_percent
    total = ack_logs.find_by_item_type("total")
    if total
      total.acknowledged_percent
    else
      0
    end
  end

  def to_s
    alert_type + ': ' + alert_type.constantize.find(id).to_s
  end

  private

  def create_console_alert_device_type
    AlertDeviceType.create!(:alert_id => self.id, :device => "Device::ConsoleDevice") unless alert_device_types.map(&:device).include?("Device::ConsoleDevice")
  end
end
