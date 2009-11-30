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
#  jurisdictional_level           :string(255)
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
#

require 'ftools'

class Alert < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :from_organization, :class_name => 'Organization'
  belongs_to :from_jurisdiction, :class_name => 'Jurisdiction'
  belongs_to :original_alert, :class_name => 'Alert'
  
  has_many :targets, :as => :item
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
  
  has_many :alert_device_types, :dependent => :delete_all
  has_many :alert_attempts, :dependent => :destroy
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

  has_one :cancellation, :class_name => 'Alert', :foreign_key => :original_alert_id, :conditions => ['message_type = ?', "Cancel"]
  has_many :updates, :class_name => 'Alert', :foreign_key => :original_alert_id, :conditions => ['message_type = ?', "Update"]

  has_attached_file :message_recording, :path => ":rails_root/:attachment/:id.:extension"

  Statuses = ['Actual', 'Exercise', 'Test']
  Severities = ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown']
  MessageTypes = { :alert => "Alert", :cancel => "Cancel", :update => "Update" }
  DeliveryTimes = [15, 60, 1440, 4320, 4420]
  
  validates_inclusion_of :status, :in => Statuses
  validates_inclusion_of :severity, :in => Severities
  validates_inclusion_of :delivery_time, :in => DeliveryTimes
  validates_length_of :short_message, :maximum => 160
  validates_length_of :caller_id, :is => 10, :allow_blank => true, :allow_nil => true
  validates_format_of :caller_id, :with => /^[0-9]*$/, :on => :create, :allow_blank => true, :allow_nil => true
  validates_attachment_content_type :message_recording, :content_type => ["audio/x-wav","application/x-wav"]
  
  before_create :set_message_type
  before_create :set_sent_at
  after_create :create_console_alert_device_type
  before_save :set_jurisdictional_level
  after_save :set_identifier
  after_save :set_distribution_id
  after_save :set_sender_id
  after_save :set_distribution_reference
  after_save :set_reference
  
  named_scope :acknowledged, :join => :alert_attempts, :conditions => "alert_attempts.acknowledged IS NOT NULL"
  named_scope :devices, {
    :select => "DISTINCT devices.type",
    :joins => "INNER JOIN alert_attempts ON alerts.id=alert_attempts.alert_id INNER JOIN deliveries ON deliveries.alert_attempt_id=alert_attempts.id INNER JOIN devices ON deliveries.device_id=devices.id",
    :conditions => "alerts.id=#{object_id}"
  }
  
  def self.new_with_defaults(options={})
    defaults = {:delivery_time => 60, :severity => 'Minor'}
    self.new(options.merge(defaults))
  end

  def cancelled?
    if cancellation.nil?
      return false
    end
    true
  end
  
  def build_cancellation(attrs={})
    attrs = attrs.stringify_keys
    changeable_fields = ["message", "severity", "sensitive", "acknowledge", "delivery_time"]
    overwrite_attrs = attrs.slice(*changeable_fields)
    self.class.new attrs.merge(self.attributes).merge(overwrite_attrs) do |alert|
      alert.created_at = nil
      alert.updated_at = nil
      alert.identifier = nil
      alert.title = "[Cancel] - #{title}"
      alert.message_type = MessageTypes[:cancel]
      alert.original_alert = self
      alert.audiences = self.audiences
    end
  end

  def build_update(attrs={})  
    attrs = attrs.stringify_keys
    changeable_fields = ["message", "severity", "sensitive", "acknowledge", "delivery_time"]
    overwrite_attrs = attrs.slice(*changeable_fields)
    self.class.new attrs.merge(self.attributes).merge(overwrite_attrs) do |alert|
      alert.created_at = nil
      alert.updated_at = nil
      alert.identifier = nil
      alert.title = "[Update] - #{title}"
      alert.message_type = MessageTypes[:update]
      alert.original_alert = self
      alert.audiences = self.audiences
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
  
  def batch_deliver
    recipients.each do |user|
      alert_attempts.create!(:user => user).batch_deliver
    end
    audiences.each do |audience|
      audience.foreign_jurisdictions.each do |jurisdiction|
        alert_attempts.create!(:jurisdiction => jurisdiction).batch_deliver  
      end
    end
    alert_device_types.each do |device_type|
      device_type.device_type.batch_deliver(self)
    end
  end
  
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

  def acknowledged_percent_for_jurisdiction(jur)
		total = attempted_users.with_jurisdiction(jur).size.to_f
		if total > 0
			acks = acknowledged_users.with_jurisdiction(jur).size.to_f
			acks / total * 100
		else
			0
		end

  end

  def acknowledged_percent_for_device(device)
		total = alert_attempts.with_device(device).size.to_f
        total = alert_attempts.size.to_f if device.device == "Device::ConsoleDevice" 
		if total > 0
			acks = alert_attempts.acknowledged_by_device(device).size.to_f
			acks / total * 100
		else
			0
		end
  end

  def integrate_voice
    original_file_name = "#{RAILS_ROOT}/message_recordings/tmp/#{self.author.token}.wav"
    if RAILS_ENV == "test"
      new_file_name = "#{RAILS_ROOT}/message_recordings/test/#{id}.wav"
    else
      new_file_name = "#{RAILS_ROOT}/message_recordings/#{id}.wav"
    end
    if File.exists?(original_file_name)
      File.move(original_file_name, new_file_name)
      m = self
      m.message_recording = File.open(new_file_name)
      m.message_recording.save
      m.save
    end
  end

  def self.default_alert
    title = "Example Health Alert - please click More to see the alert contents"
    message = "This is an example of a health alert.  You can see the title above and this is the alert body.\n\nThe status lets you know if this is an actual alert or just a test alert.  The severity lets you know the level of severity from Minor to Extreme severity.  The sensitive indicator lets you know if the alert is of a sensitive nature.\n\nYou can also see if the alert requires acknowledgment.  If the alert does require acknowlegment, an acknowledge button will appear so you can acknowledge the alert."
    Alert.new(:title => title, :message => message, :severity => "Minor", :created_at => Time.zone.now, :status => "Test", :acknowledge => false, :sensitive => false)
  end

  def set_jurisdictional_level
    if !Jurisdiction.find_by_name(sender).nil?
      jurs = Jurisdiction.foreign.find(:all, :conditions => ['id in (?)', audiences.map(&:jurisdiction_ids).flatten.uniq])
      level=[]
      level << "Federal" if jurs.detect{|j| j.root?}
      level << "State" if jurs.detect{|j| !j.root? && !j.leaf?}
      level << "Local" if jurs.detect{|j| j.leaf?}
      write_attribute("jurisdictional_level",  level.join(","))
    end
  end

  def set_sent_at
    if sent_at.blank?
      write_attribute("sent_at", Time.zone.now)
    end
  end

  def sender
    from_jurisdiction.nil? ? from_organization_name :  from_jurisdiction.name
  end

  def self.sender_id
    "#{Agency[:agency_identifer]}@#{Agency[:agency_domain]}"
  end

  def to_ack_edxl
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.EDXLDistribution(:xmlns => 'urn:oasis:names:tc:emergency:EDXL:DE:1.0') do
      xml.distributionID "#{identifier},#{Agency[:agency_identifier]}"
      xml.senderID "#{Agency[:agency_identifier]}@#{Agency[:agency_domain]}"
      xml.dateTimeSent Time.now.utc.iso8601(3)
      xml.distributionStatus status
      xml.distributionType "Ack"
      xml.combinedConfidentiality sensitive? ? "Sensitive" : "NotSensitive"
      xml.distributionReference ack_distribution_reference
    end

  end

  def recipients
    (targets.map(&:users).flatten + User.find(required_han_coordinators)).uniq
  end

  def total_jurisdictions
    (audiences.map(&:jurisdictions).flatten + recipients.map(&:jurisdictions).flatten).uniq
  end
  
  # used by Target to determine if public users should be included in recipients
  def include_public_users?
    true
  end

private
  def set_message_type
    self.message_type = MessageTypes[:alert] if self.message_type.blank?
  end
  
  def set_identifier
    if identifier.nil?
      write_attribute(:identifier, "#{Agency[:agency_abbreviation]}-#{Time.zone.now.strftime("%Y")}-#{id}")
      self.save!
    end
  end

  def set_distribution_id
    if distribution_id.nil? || (!original_alert.nil? && distribution_id == original_alert.distribution_id)
      write_attribute(:distribution_id, "#{Agency[:agency_abbreviation]}-#{created_at.strftime("%Y")}-#{id}")
      self.save!
    end
  end

  def set_sender_id
    if sender_id.nil?
      write_attribute(:sender_id, "#{Agency[:agency_identifier]}@#{Agency[:agency_domain]}")
      self.save!
    end
  end

  def set_distribution_reference
    if !original_alert.nil? && distribution_reference.nil?
      write_attribute(:distribution_reference, "#{original_alert.distribution_id},#{sender_id},#{original_alert.sent_at.utc.iso8601(3)}")
      self.save!
    end
  end

  def set_reference
    if !original_alert.nil? && reference.nil?
      write_attribute(:reference, "#{Agency[:agency_identifier]},#{original_alert.distribution_id},#{original_alert.sent_at.utc.iso8601(3)}")
      self.save!
    end
  end
  
  def required_han_coordinators
    # Keith says: "Do not fuck with this method."
    jurisdictions = audiences.map(&:jurisdictions).flatten.uniq
    unless jurisdictions.empty?
      # grab all jurisdictions we're sending to, plus the from jurisdiction and get their ancestors
      if from_jurisdiction.nil?
        return (jurisdictions.compact.map(&:self_and_ancestors).flatten.uniq - (Jurisdiction.federal)).map{|jurisdiction| jurisdiction.han_coordinators.map(&:id)}.flatten
      else
        selves_and_ancestors = (jurisdictions + [from_jurisdiction]).compact.map(&:self_and_ancestors)
      end

      # union them all, but that may give us too many ancestors
      unioned = selves_and_ancestors[1..-1].inject(selves_and_ancestors.first){|union, list| list | union}

      # intersecting will give us all the ancestors in common
      intersected = selves_and_ancestors[1..-1].inject(selves_and_ancestors.first){|intersection, list| list & intersection}

      # So we grab the lowest common ancestor; ancestory at the lowest level
      good_ones = (unioned - intersected) + [intersected.max{|x,y| x.level <=> y.level }]

      # Finally, grab all those han coordinators
      good_ones.compact.map {|jurisdiction| jurisdiction.han_coordinators.map(&:id) }.flatten
    else
      []
    end 
  end

  def create_console_alert_device_type
    AlertDeviceType.create!(:alert => self, :device => "Device::ConsoleDevice")
  end
end
