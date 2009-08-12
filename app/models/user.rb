# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
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
#  email_confirmed    :boolean(1)      not null
#  phone              :string(255)
#  delta              :boolean(1)
#  credentials        :text
#  bio                :text
#  experience         :text
#  employer           :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  public             :boolean(1)
#  photo_file_size    :integer(4)
#  photo_updated_at   :datetime
#

# Required Attributes: :cn, :sn, :organizations

class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :devices, :dependent => :delete_all
  accepts_nested_attributes_for :devices
  
  has_many :role_memberships, :dependent => :delete_all
  has_many :role_requests, :foreign_key => "requester_id", :dependent => :delete_all
  accepts_nested_attributes_for :role_requests
  
  has_many :organizations, :primary_key => :email, :foreign_key => 'contact_email'
  has_many :jurisdictions, :through => :role_memberships 
  has_many :roles, :through => :role_memberships
  has_many :alerts, :foreign_key => 'author_id'
  has_many :alert_attempts
  has_many :received_alerts, :through => :alert_attempts, :source => 'alert', :order => "alerts.created_at DESC"
  has_many :deliveries, :through => :alert_attempts
  has_many :recent_alerts, :through => :alert_attempts, :source => 'alert', :limit => 20, :order => "alerts.created_at DESC"

  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name
  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, :organization_ids, :role_requests_attributes, :credentials, :bio, :experience, :employer, :photo_file_name, :photo_content_type, :public, :photo_file_size, :photo_updated_at
    
  has_attached_file :photo, :default_url => '/images/missing.jpg', :styles => { :medium => "200x200>" }
	
	def editable_by?(other_user)
	  self == other_user || jurisdictions.any?{|j| other_user.is_admin_for?(j) }
  end
    
  before_create :generate_oid
  before_create :set_confirmation_token
  before_create :create_default_email_device

  after_create :assign_public_role

  named_scope :with_role, lambda {|role| 
    role = role.is_a?(Role) ? role : Role.find_by_name(role)
    { :conditions => [ "role_memberships.role_id = ?", role.id ]}
  }
  named_scope :with_jurisdiction, lambda {|jurisdiction|
    jurisdiction = jurisdiction.is_a?(Jurisdiction) ? jurisdiction : Jurisdiction.find_by_name(jurisdiction)
    { :conditions => [ "role_memberships.jurisdiction_id = ?", jurisdiction.id ], :include => :role_memberships}
  }

#  named_scope :acknowledged_alert, lamda {|alert|
#	  { :include => :alert_attempts, :conditions => ["alert_attempts.acknowledged_at is not null"] }
#  }
  
  named_scope :alphabetical, :order => 'last_name, first_name, display_name'
  
  define_index do
    indexes first_name, :sortable => true
    indexes last_name, :sortable => true
    indexes display_name
    indexes title

    set_property :delta => :delayed
  end
  
  def self.assign_role(role, jurisdiction, users)
    users.each do |u|
      u.role_memberships.create(:role => role, :jurisdiction => jurisdiction)
    end
  end

  def is_admin_for?(jurisdiction)
    jurisdiction.admins.include?(self)
  end
  
  def is_super_admin?
    j = Jurisdiction.find_by_name('Texas')
    j.admins.include?(self) unless j.nil?
  end

  def is_admin?
    self.jurisdictions.each do |j|
      return true if j.admins.include?(self)
    end
    false
  end

  def is_org_approver?
    self.roles.detect{|role| role == Role.org_admin }
  end
  
  def has_non_public_role?
    self.roles.any?{|role| role.approval_required? }
  end

  def display_name
    self[:display_name].blank? ? first_name + " " + last_name : self[:display_name]
  end
  alias_method :name, :display_name
  
  def alerter_jurisdictions
    Jurisdiction.find(role_memberships.alerter.map(&:jurisdiction_id))
  end
  
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
  
  def alerter?
    !role_memberships.alerter.empty?
  end
  
  def formatted_email
    "#{name} <#{email}>"
  end
  
  def viewable_alerts
    alerts_within_jurisdictions | alerts | received_alerts
  end
  
  def alerts_within_jurisdictions
    j = jurisdictions.map{|m| m.self_and_descendants}.flatten
    Alert.all(:conditions => {:from_jurisdiction_id => j})
  end

  def generate_upload_token
    filename = "#{RAILS_ROOT}/message_recordings/tmp/#{self.token}.wav"
    if File.exists?(filename)
      File.delete(filename)
    end
    self.token = ActiveSupport::SecureRandom.hex
    self.token_expires_at = Time.zone.now+10.minutes
    self.save
    return self.token
  end

private

  def assign_public_role
    public_role = Role.find_by_name("Public")
    role_requests.find_all_by_role_id(public_role).each do |request|
      if request.approver.nil?
        role_memberships.create!(
          :role => public_role, 
          :jurisdiction => request.jurisdiction
        )
      end
      request.destroy
    end
        
    if self.role_requests.any?
      self.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(
        public_role.id, 
        self.role_requests.first.jurisdiction.id
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
