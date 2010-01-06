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

class User < ActiveRecord::Base
  extend Clearance::User::ClassMethods
  include Clearance::User::InstanceMethods
  include Clearance::User::AttrAccessible
  include Clearance::User::AttrAccessor
  include Clearance::User::Callbacks

  has_many :devices, :dependent => :delete_all
  accepts_nested_attributes_for :devices
  
  has_many :role_memberships, :include => :jurisdiction, :dependent => :delete_all
  has_many :role_requests, :dependent => :delete_all
  accepts_nested_attributes_for :role_requests

  has_many :organizations, :primary_key => :email, :foreign_key => 'contact_email'
  has_many :jurisdictions, :through => :role_memberships, :uniq => true
  has_many :roles, :through => :role_memberships, :uniq => true 
  has_many :alerting_jurisdictions, :through => :role_memberships, :source => 'jurisdiction', :include => {:role_memberships => [:role]}, :conditions => ['roles.alerter = ?', true]
  has_many :alerts, :foreign_key => 'author_id'
  has_many :alert_attempts
  has_many :deliveries,    :through => :alert_attempts
  has_many :recent_alerts, :through => :alert_attempts, :source => 'alert', :limit => 20, :order => "alerts.created_at DESC"
#  has_many :viewable_alerts, :through => :alert_attempts, :source => "alert", :order => "alerts.created_at DESC"
  has_many :groups, :foreign_key => "owner_id", :source => "user"
  has_many :documents do
    def inbox
      scoped :conditions => 'documents.folder_id IS NULL'
    end
  end
  has_many :folders  do
    def rootsm
      scoped :conditions => 'folders.parent_id IS NULL'
    end
  end
  has_many :subscriptions
  has_many :channels, :through => :subscriptions
  has_many :owned_channels, :through => :subscriptions, :source => 'channel', :conditions => {:subscriptions => {:owner => true}}



  validates_presence_of     :email
  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_length_of       :password, :minimum => 6, :too_short => "must be at least 6 characters long", :if => :password_required?
  validates_format_of       :password, :with => /(?=[-_a-zA-Z0-9]*?[A-Z])(?=[-_a-zA-Z0-9]*?[a-z])(?=[-_a-zA-Z0-9]*?[0-9])[-_a-zA-Z0-9]/, :message => "does not meet minimum complexity requirements\nPassword must contain at least one upper case letter, one lower case letter, and one digit", :if => :password_required?
  validates_format_of       :email, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,})[^\.]$}
  validates_uniqueness_of   :email, :message => "address is already being used on another user account.  If you have forgotten your password, please visit the sign in page and click the Forgot password? link."
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_associated :role_requests
  validates_associated :role_memberships

  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, :organization_ids, :role_requests_attributes, :credentials, :bio, :experience, :employer, :photo_file_name, :photo_content_type, :public, :photo_file_size, :photo_updated_at
    
  has_attached_file :photo, :default_url => '/images/missing.jpg', :styles => { :medium => "200x200>" }
	
	def editable_by?(other_user)
	  self == other_user || jurisdictions.any?{|j| other_user.is_admin_for?(j) }
  end
    
  before_create :generate_oid
  before_create :set_confirmation_token
  before_create :create_default_email_device
  before_create :set_display_name

  after_create :assign_public_role

  named_scope :with_role, lambda {|role| 
    role = role.is_a?(Role) ? role : Role.find_by_name(role)
    { :conditions => [ "role_memberships.role_id = ?", role.id ], :include => :role_memberships}
  }
  named_scope :with_roles, lambda {|roles|
    roles = roles.map{|role| role.is_a?(Role) ? role : Role.find_by_name(role)}
    { :conditions => [ "role_memberships.role_id in (?)", roles.map(&:id) ], :include => :role_memberships}
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
    indexes email
  
    set_property :delta => :delayed
  end

   #TODO Move this into plugin for rollcall later
  def school_districts
    jurisdictions.map{|jur| jur.school_districts}.flatten.uniq
  end

  def schools(options={})
    options={ :conditions => ["district_id in (?)", school_districts.map(&:id)], :order => "name"}.merge(options)
    School.find(:all, options)
#    school_districts.map{|district| district.schools}.flatten.uniq
  end

  def recent_absentee_reports
    schools.map{|school| school.absentee_reports.absenses.recent(20).sort_by{|report| report.report_date}}.flatten.uniq[0..19].sort_by{|report| report.school_id}
  end
	def visible_groups
		@_visible_groups ||= (groups | Group.find_all_by_owner_jurisdiction_id_and_scope(jurisdictions.map(&:id), "Jurisdiction") | Group.find_all_by_scope("Global")).sort{|a,b| a.name <=> b.name}
  end

  def self.assign_role(role, jurisdiction, users)
    users.each do |u|
      u.role_memberships.create(:role => role, :jurisdiction => jurisdiction)
    end
  end

  def is_admin_for?(other)
    return true if roles.include?(Role.superadmin)
    if other.class == Jurisdiction
      return true if role_memberships.detect{|r| r.role==Role.admin && other.is_or_is_descendant_of?(r.jurisdiction)}
    elsif other.class == Array
      other.each do |jurisdiction|
        return true if role_memberships.detect{|r| r.role==Role.admin && jurisdiction.is_or_is_descendant_of?(r.jurisdiction)}
      end
      false
    else
      false
    end
    false
  end

  def is_alerter_for?(jurisdiction)
    jurisdiction.alerting_users.include?(self)
  end
  
  def is_super_admin?
    j = Jurisdiction.find_by_name('Texas')
    j.super_admins.include?(self) unless j.nil?
  end

  def is_admin?
    self.roles.include?(Role.admin) || self.roles.include?(Role.superadmin) ? true : false
  end

  def is_jurisdiction_admin?
    self.roles.include?(Role.admin)
  end

  def is_org_approver?
    self.roles.detect{|role| role == Role.org_admin }
  end
  
  def has_non_public_role?
    self.roles.any?{|role| role.approval_required? || role == Role.admin || role == Role.superadmin }
  end

  def has_public_role?
    self.roles.any?{|role| role == Role.public}
  end

  def has_public_role_in?(jurisdiction)
    self.role_memberships.any?{|rm| rm.role == Role.public && rm.jurisdiction == jurisdiction}
  end


  def has_public_role_request?
    self.role_requests.any?{|request| request.role == Role.public}
  end

  alias_attribute :name, :display_name
  
  def alerter_jurisdictions
    Jurisdiction.find(role_memberships.alerter.map(&:jurisdiction_id))
  end
  
  def phin_oid=(val)
    raise "PHIN oids should never change"
  end
  
  def has_uploaded?
    filename = "#{RAILS_ROOT}/message_recordings/tmp/#{token}.wav"
    return File.exists?(filename)
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
 
  def alerter?
    !role_memberships.alerter.empty?
  end

  def formatted_email
    "#{name} <#{email}>"
  end
  
  def viewable_alerts
      (alerts_within_jurisdictions | recent_alerts).sort!{|a,b| b.created_at.utc.to_datetime <=> a.created_at.utc.to_datetime}
  end
  
  def alerts_within_jurisdictions
    j = jurisdictions.map{|m| m.self_and_descendants}.flatten
    Alert.all(:conditions => {:from_jurisdiction_id => j}, :order => "alerts.created_at DESC")
  end
  
  def cascade_alerts
    #j = jurisdictions.uniq.map{|j| j }
    #alerts.reject{|alert|
    #  alert.jurisdictions.include?(j)
    #}
      #Alert.find_all_by_jurisdiction_id(:conditions => {:jurisdiction => j}, :order => "alerts.created_at DESC")
    #}
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

  def viewable_groups
    groups | Group.jurisdictional.by_jurisdictions(jurisdictions) | Group.global
  end
   
private

  def assign_public_role
    public_role = Role.public
    if (role_requests.nil? && role_memberships.nil?) || (!role_requests.map(&:role_id).flatten.include?(public_role.id) && !role_memberships.map(&:role_id).flatten.include?(public_role.id))
      role_memberships.create!(:role => public_role, :jurisdiction => Jurisdiction.state.first) unless Jurisdiction.state.empty?
    else
      rr = role_requests
      rr.each do |request|
        role_memberships.create!(:role => public_role, :jurisdiction => request.jurisdiction)
        RoleRequest.find_by_id(request.id).destroy
      end unless role_requests.nil? || role_memberships.public_roles.count != 0
      role_memberships.each do |request|
        role_memberships.create!(:role => public_role, :jurisdiction => request.jurisdiction)
      end if role_memberships.public_roles.count == 0
    end

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

  def set_display_name
    self.display_name = "#{self.first_name.strip} #{self.last_name.strip}" if self.display_name.nil? || self.display_name.strip.blank?
  end
  
end
