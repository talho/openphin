# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  last_name          :string(255)
#  phin_oid           :string(255)
#  description        :text
#  display_name       :string(255)
#  first_name         :string(255)
#  email              :string(255)
#  preferred_language :string(255)
#  title              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(128)
#  salt               :string(128)
#  token              :string(128)
#  token_expires_at   :datetime
#  email_confirmed    :boolean         not null
#  phone              :string(255)
#

# Required Attributes: :cn, :sn, :organizations

class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :devices
  has_many :role_memberships
  has_many :role_requests, :foreign_key => "requester_id"
  accepts_nested_attributes_for :role_requests
  
  has_and_belongs_to_many :organizations
  has_many :jurisdictions, :through => :role_memberships 
  has_many :roles, :through => :role_memberships
  has_many :alerts, :foreign_key => 'author_id'
  has_many :deliveries
  has_one :profile, :class_name => "UserProfile"

  validates_uniqueness_of :email
  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name
  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, :organization_ids, :role_requests_attributes
    
  before_create :generate_oid
  before_create :set_confirmation_token
  before_create :create_default_email_device

  after_create :assign_public_role
  
  named_scope :with_role, lambda {|role| 
    { :conditions => [ "role_memberships.role_id = ?",  Role.find_by_name(role).id ]}
  }
  
  named_scope :alphabetical, :order => 'last_name, first_name, display_name'
  
  def self.search(query)
    all(:conditions => ['first_name LIKE :query OR last_name LIKE :query OR display_name LIKE :query OR title LIKE :query', {:query => "%#{query}%"}])
  end

  def is_admin_for?(jurisdiction)
    jurisdiction.admins.include?(self)
  end

  def display_name
    self[:display_name].blank? ? first_name + " " + last_name : self[:display_name]
  end
  alias_method :name, :display_name
  
  def phin_oid=(val)
    raise "PHIN oids should never change"
  end

  def to_dsml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml:objectclass do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "person"
        oc.dsml ocv, "organizationalPerson"
        oc.dsml ocv, "inetOrgPerson"
        oc.dsml ocv, "User"

      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :sn) {|a| a.dsml :value, sn}
      entry.dsml(:attr, :name => :externalUID) {|a| a.dsml :value, externalUID}
      entry.dsml(:attr, :name => :description) {|a| a.dsml :value, description}
      entry.dsml(:attr, :name => :displayName) {|a| a.dsml :value, displayName}
      entry.dsml(:attr, :name => :givenName) {|a| a.dsml :value, givenName}
      entry.dsml(:attr, :name => :mail) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :preferredlanguage) {|a| a.dsml :value, preferredlanguage}
      entry.dsml(:attr, :name => :title) {|a| a.dsml :value, title}
      entry.dsml(:attr, :name => :roles) do |r|
        phinroles.each do |role|
          r.dsml(:value, role.cn)
        end
      end
      entry.dsml(:attr, :name => :roleJurisdiction) {|a| a.dsml :value, roleJurisdiction}
      entry.dsml(:attr, :name => :organizations) do |o|
        organizations.each do |org|
          o.dsml(:value, org)
        end
      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, cn}

    end
  end

  def request_roles
    role_memberships.each do |rm|
      if rm.needs_approval?
        rm.request_approval
      end
    end
  end
  
private

  def assign_public_role
    if self.role_requests.any?
      self.role_memberships.create!(
        :role => Role.find_by_name("Public"), 
        :jurisdiction => self.role_requests.first.jurisdiction
      )
    end
  end

  def generate_oid
    self[:phin_oid] = email.to_phin_oid
  end
  
  def create_default_email_device  
    email = Device::EmailDevice.new(:email_address => self.email)
    devices << email
  end
    
  def set_confirmation_token
    self.token = ActiveSupport::SecureRandom.hex
  end

end
