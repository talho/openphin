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
#  call_down_messages             :text
#  not_cross_jurisdictional       :boolean(1)     default(true)
#

require 'ftools'

class Alert < ActiveRecord::Base
  acts_as_MTI

  serialize :call_down_messages, Hash

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
  after_create :batch_deliver

  named_scope :acknowledged, :join => :alert_attempts, :conditions => "alert_attempts.acknowledged IS NOT NULL"
  named_scope :devices, {
      :select => "DISTINCT devices.type",
      :joins => "INNER JOIN alert_attempts ON alerts.id=alert_attempts.alert_id INNER JOIN deliveries ON deliveries.alert_attempt_id=alert_attempts.id INNER JOIN devices ON deliveries.device_id=devices.id",
      :conditions => "alerts.id=#{object_id}"
  }
  named_scope :has_acknowledge, :conditions => ['acknowledge = ?', true]
  before_create :set_alert_type

  def self.default_alert
    title = "Example Alert - please click More to see the alert contents"
    message = "This is an example of ah alert.  You can see the title above and this is the alert body.\n\nThe status lets you know if this is an actual alert or just a test alert."
    Alert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end

  def self.child_classes
    Module.constants.map{|constant_name| constant_name.constantize if !(defined? constant_name.constantize.superclass).nil? && constant_name.constantize.superclass == ::Alert}.compact
  end

#  def superclass
#    self.class.superclass
#  end

  def alert_identifier
    id
  end

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
    (alert_type.nil? || alert_type == "Alert") ? self.title : alert_type + ':' + alert_type.constantize.find(id).to_s
  end

  def to_xml(options={})
    options={} if options.blank?
    builder=Builder::XmlMarkup.new( :indent => 2)
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.TMAPI(:messageId => options[:messageId].blank? ? "#{self.class}-#{self.id}" : options[:messageId]) do |tmapi|
      xml_build_author tmapi, options[:Author]
      xml_build_behavior tmapi, options[:Behavior]
      xml_build_messages tmapi, options[:Messages]
      xml_build_ivrtree tmapi, options[:IVRTree]
      xml_build_recipients tmapi, options[:Recipients]
    end
  end
#
#  def to_json
#
#  end

  def batch_deliver &block
    recipients.each do |user|
      alert_attempts.create!(:user => user).batch_deliver
    end
    yield if block_given?
    ::MessageApi.deliver(self)
#    alert_device_types(true).each do |device_type|
#      device_type.device_type.batch_deliver(self)
#    end
    self.initialize_statistics
  end

  def initialize_statistics
    self.reload
    aa_size = alert_attempts(true).size.to_f

    types = (alert_device_types.map(&:device) << "Device::ConsoleDevice").uniq
    types.each do |type|
      ack_logs.create(:item_type => "device", :item => type, :acks => 0, :total => aa_size)
    end

    ack_logs.create(:item_type => "total", :acks => 0, :total => aa_size)
  end

  def update_statistics(options)
    aa_size = nil
    
    if options[:response] && options[:response].to_i > 0
      response = options[:response]
      ack = ack_logs.find_by_item_type_and_item("alert_response", call_down_messages[options[:response]])
      ack.update_attribute(:acks, ack[:acks] + 1) unless ack.nil?
    end

    if options[:device]
      ack = ack_logs.find_by_item_type_and_item("device",options[:device])
      ack.update_attribute(:acks, ack[:acks] + 1) unless ack.nil?
    end

    ack = ack_logs.find_by_item_type("total")
    ack.update_attribute(:acks, ack[:acks] + 1) unless ack.nil?
  end

  private

  def create_console_alert_device_type
    AlertDeviceType.create!(:alert_id => self.id, :device => "Device::ConsoleDevice") unless alert_device_types.map(&:device).include?("Device::ConsoleDevice")
  end

  def xml_build_author builder, options={}
    options={} if options.blank?
    unless self.author.blank?
      builder.Author(:givenName => self.author.first_name, :surname => self.author.last_name, :display_name => self.author.display_name) do |a|
        if options[:override]
          options[:override].call(a)
        else
          a.Contact(:device_type => "E-mail") do |contact|
            contact.Value self.author.email
          end

          options[:supplement].call(a) if options[:supplement]
        end
      end
    end
  end

  def xml_build_behavior builder, options={}
    options={ :Delivery => {:Providers => {} } } if options.blank?
    builder.Behavior do |behavior|
      if options[:override]
        options[:override].call(behavior)
      else
        if options[:Delivery]
          behavior.Delivery do |delivery|
            if options[:Delivery][:override]
              options[:Delivery][:override].call(delivery)
            else
              if options[:Delivery][:Providers]
                delivery.Providers do |providers|
                  if options[:Delivery][:Providers][:override]
                    options[:Delivery][:Providers][:override].call(providers)
                  else
                    (self.alert_device_types.map{|device| device.device_type.display_name} || Service::SWN::Message::SUPPORTED_DEVICES.keys).each do |device|
                      device_options = {:name => "swn", :device => device}
                      device_options[:ivr] = "alert_responses" if self.acknowledge?
                      providers.Provider(device_options)
                    end

                    options[:Delivery][:Providers][:supplement].call(providers) if options[:Delivery][:Providers][:supplement]
                  end
                end
              end

              options[:Delivery][:supplement].call(delivery) if options[:Delivery][:supplement]
            end
          end
        end

        options[:supplement].call(behavior) if options[:supplement]
      end
    end
  end

  def xml_build_messages builder, options={}
    options={} if options.blank?
    builder.Messages do |messages|
      if options[:override]
          options[:override].call(messages)
      else
        messages.Message(:name => "title", :lang => "en/us", :encoding => "utf8", :content_type => "text/plain") do |message|
          message.Value self.title
        end

        messages.Message(:name => "message", :lang => "en/us", :encoding => "utf8", :content_type => "text/plain") do |message|
          message.Value self.message
        end

        options[:supplement].call(messages) if options[:supplement]
      end
    end
  end

  def xml_build_ivrtree builder, options={}
    options={} if options.blank?
    builder.IVRTree do |ivrtree|
      if options[:override]
          options[:override].call(ivrtree)
      elsif self.acknowledge?
        ivrtree.IVR(:name => "alert_responses") do |ivr|
          ivr.RootNode(:operation => "start") do |rootnode|
            sorted_messages = self.call_down_messages.sort {|a, b| a[0]<=>b[0]}
            sorted_messages.each do |key, call_down|
              rootnode.ContextNode do |node|
                node.label key
                node.operation "TTS"
                node.response call_down
              end
            end
            rootnode.ContextNode do |response_node|
              response_node.label "Prompt"
              response_node.operation "Prompt"
            end
          end
        end

        options[:supplement].call(ivrtree) if options[:supplement]
      end
    end
  end

  def xml_build_recipients builder, options={}
    options={} if options.blank?
    builder.Recipients do |rcpts|
      if options[:override]
        options[:override].call(rcpts)
      else
        # Can't use recipients association since find_each doesn't append the LIMIT to it properly
        User.find_each(:joins => "INNER JOIN targets_users ON targets_users.user_id=users.id INNER JOIN targets ON targets_users.target_id=targets.id AND targets.item_type='#{self.class.to_s}'", :conditions => ['targets.item_id = ?', self.id]) do |recipient|
          rcpts.Recipient(:id => recipient.id, :givenName => recipient.first_name, :surname => recipient.last_name, :display_name => recipient.display_name) do |rcpt|
            (recipient.devices.find_all_by_type(self.alert_device_types.map(&:device))).each do |device|
              rcpt.Device(:id => device.id, :device_type =>  device.class.display_name) do |d|
                d.URN device.URN
              end
            end
          end
        end

        options[:supplement].call(rcpts) if options[:supplement]
      end
    end
  end

  private
  def set_alert_type
    self[:alert_type] = "Alert"
  end

end
