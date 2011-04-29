require 'active_record/validations'
require 'happymapper'

module ObjectValidation
  def self.included(base)
      base.send :extend, ClassMethods
  end

  def initialize(*args)
    @errors = ActiveRecord::Errors.new(self)
  end

  def save

  end

  def save!

  end

  def new_record?
    false
  end

  def update_attribute

  end

  module ClassMethods
    def human_name options={}
      self.name.humanize
    end

    def human_attribute_name attribute_key_name, options={}
      attribute_key_name.humanize
    end

    def self_and_descendants_from_active_record
      [self.superclass]
    end
  end
end

class MessageApi
  include HappyMapper
  include ObjectValidation
  include ActiveRecord::Validations

  validates_presence_of :messageId
  validates_presence_of :Author, :message => "You must include an Author tag"
  validates_associated :Author
  validates_associated :Behavior
  validates_length_of :Messages, :minimum => 1
  validates_associated :Messages
  validates_associated :IVRTree
  validates_length_of :Recipients, :minimum => 1
  validates_associated :Recipients

  def self.deliver item
    message = self.parse(case item.class
    when String
      comparer = "<?xml"
      if item[0..(comparer.length - 1)] == comparer
        item
      else
        raise "Malformed XML document"
      end
    when Hash
      item.as_json.to_xml
    else
      if item.respond_to?('to_xml')
        item.to_xml
      else
        raise "Object does not support to_xml"
      end
    end)

     Service::Base.dispatch message
  end

  class ContextNode
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_length_of :operation, :minimum => 1    

    tag "ContextNode"
    has_one :label, String, :attributes => {:name => String}
    has_one :operation, String, :attributes => {:name => String}
    has_one :response, String, :attributes => {:ref => String}
    has_many :ContextNodes, ContextNode
    attribute :name, String
  end

  class Authentication
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

#    validates_length_of :Username, :is => 1
#    validates_length_of :Password, :is => 1

    tag "Authentication"
    has_one :Username, String
    has_one :Password, String
  end

  class Author
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    class Contact
      include HappyMapper
      include ObjectValidation
      include ActiveRecord::Validations

      validates_presence_of :Value

      tag "Contact"
      has_one :Value, String
      attribute :device_type, String
      attribute :label, String
    end

    validates_length_of :Contacts, :minimum => 1, :message => "Author must have at least one Contact tag"
    validate do |record|
      record.Contacts.each do |contact|
        record.errors.add "device", "Contact device not email, phone, xmpp, fascimile, or sms" unless MessageApi.communication_device_names.include?(contact.device_type.strip)
      end
    end
    validates_presence_of :givenName
    validates_presence_of :surname

    tag "Author"
    has_many :Contacts, Contact
    attribute :display_name, String
    attribute :givenName, String
    attribute :surname, String
  end

  class CustomAttribute
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_presence_of :Value
    validates_presence_of :name

    tag "customAttribute"
    has_one :Value, String
    attribute :name, String
  end

  class ProviderMessage
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_presence_of :name
    validate do |record|
      record.errors.add "ProviderMessage", "Provider must specify a message or reference a named message" if record.Value.blank? && record.ref.blank?
    end

    tag "ProviderMessage"
    has_one :Value, String
    attribute :name, String
    attribute :ref, String
  end

  class Provider
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_length_of :customAttributes, :maximum => 1, :message => "customAttributes cannot be specified more than once"
    validates_presence_of :name
    validates_presence_of :device
    validate do |record|
      record.errors.add "device", "Provider device not email, phone, xmpp, fascimile, or sms" unless MessageApi.communication_device_names.include?(record.device.strip)
    end
    validates_associated :customAttributes

    tag "Provider"

    has_many :Messages, ProviderMessage
    has_many :customAttributes, CustomAttribute
    has_one :allowDuplicates, Boolean
    attribute :name, String
    attribute :version, String
    attribute :device, String
    attribute :ivr, String
  end

  class Delivery
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_associated :Providers

    tag "Delivery"
    has_many :Providers, Provider
    has_many :customAttributes, CustomAttribute
    attribute :start, Date
    attribute :end, Date
    attribute :defaultProvider, String
  end

  class Behavior
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_associated :Delivery

    tag "Behavior"
    has_one :Delivery, Delivery
  end

  class Message
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_presence_of :Value
    validates_presence_of :name

    tag "Message"
    has_one :Value, String
    attribute :name, String
    attribute :lang, String
    attribute :encoding, String
    attribute :content_type, String
  end

  class IVR
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_presence_of :name

    tag "IVR"
    has_many :ContextNodes, ContextNode
    attribute :name, String
  end

  class Device
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_presence_of :URN
    validate do |record|
      record.errors.add "device", "Provider device not email, phone, xmpp, fascimile, or sms" unless MessageApi.communication_device_names.include?(record.device_type.strip)
    end

    tag "Device"
    has_one :URN, String
    has_one :Options, String
    has_one :Message, Message
    attribute :id, String
    attribute :device_type, String
    attribute :priority, Integer
    attribute :provider, String
  end

  class Recipient
    include HappyMapper
    include ObjectValidation
    include ActiveRecord::Validations

    validates_length_of :Devices, :minimum => 1
    validates_associated :Devices
    validates_presence_of :id
    validates_presence_of :givenName
    validates_presence_of :surname

    tag "Recipient"
    has_many :Devices, Device
    attribute :id, String
    attribute :givenName, String
    attribute :surname, String
    attribute :display_name, String
  end

  tag "TMAPI"
  has_one :Authentication, Authentication
  has_one :Author, Author
  has_one :Behavior, Behavior
  has_many :Messages, Message
  has_many :IVRTree, IVR
  has_many :Recipients, Recipient
  attribute :messageId, String

  def self.communication_device_names
    ::Device.constants.select{|x| x[-6..-1] == "Device"}.map{|name| "Device::#{name}"}.map(&:constantize).map(&:display_name)
  end
end