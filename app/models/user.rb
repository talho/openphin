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
#  email_confirmed    :boolean(1)      default(FALSE), not null
#  phone              :string(255)
#  delta              :boolean(1)      default(TRUE), not null
#  credentials        :text
#  bio                :text
#  experience         :text
#  employer           :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  public             :boolean(1)
#  photo_file_size    :integer(4)
#  photo_updated_at   :datetime
#  deleted_at         :datetime
#  deleted_by         :string(255)
#  deleted_from       :string(24)
#  home_phone         :string(255)
#  mobile_phone       :string(255)
#  fax                :string(255)
#

class User < ActiveRecord::Base
  include Clearance::User  
  
  has_many :devices, :dependent => :delete_all
  accepts_nested_attributes_for :devices
  
  has_many :organization_membership_requests, :dependent => :delete_all

  include UserModules::Roles
  
  has_many :jurisdictions, :through => :role_memberships, :uniq => true
  def alerting_jurisdictions
    Jurisdiction.joins(:role_memberships => [:role, :user]).where(:roles => {:alerter => true}, :users => {:id => self.id})
  end
  has_many :alerts, :foreign_key => 'author_id'
  has_many :alert_attempts, :include => [:jurisdiction, :organization, :user, :acknowledged_alert_device_type, :devices]
  has_many :deliveries,    :through => :alert_attempts
#  has_many :viewable_alerts, :through => :alert_attempts, :source => "alert", :order => "alerts.created_at DESC"
  has_many :groups, :foreign_key => "owner_id", :source => "user"

  include UserModules::Dashboard
  include UserModules::Forum
  
  has_many :documents, :foreign_key => 'owner_id' do
    def inbox
      where('documents.folder_id IS NULL')
    end      
    def expiring_soon
      where("created_at <= ? and created_at > ?", 25.days.ago, 26.days.ago)
    end
  end
  has_many :folders  do
    def rootsm
      where('folders.parent_id IS NULL')
    end
  end

  #has_many :subscriptions
  #has_many :shares, :through => :subscriptions
  has_many :folder_permissions
  has_many :authoring_folders, :through => :folder_permissions, :source => :folder, :conditions => ['folder_permissions.permission = 1']
  has_many :admin_folders, :through => :folder_permissions, :source => :folder, :conditions => ['folder_permissions.permission = 2']
  has_and_belongs_to_many :audiences, :finder_sql => proc { "SELECT a.* FROM audiences a JOIN sp_audiences_for_user(#{self.id}) sp ON a.id = sp.id"}

  def shares
    Folder.where('folders.audience_id IN (SELECT * FROM sp_audiences_for_user(?)) and (folders.user_id IS NULL OR folders.user_id != ?)', self.id, self.id).includes(:owner, :folder_permissions)
  end

  def shared_documents
    Document.where('folders.audience_id IN (SELECT * FROM sp_audiences_for_user(?)) and (folders.user_id IS NULL OR folders.user_id != ?)', self.id, self.id).includes(:owner, :folder)
  end

  has_many :favorites

  has_many :reports, :class_name => 'Report::Report', :foreign_key => "author_id"
  has_many :recipes

  validates_presence_of     :email
  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_length_of       :password, :minimum => 6, :too_short => "must be at least 6 characters long", :if => :password_required?
  validates_format_of       :password, :with => /(?=[-_a-zA-Z0-9]*?[A-Z])(?=[-_a-zA-Z0-9]*?[a-z])(?=[-_a-zA-Z0-9]*?[0-9])[-_a-zA-Z0-9]/, :message => "does not meet minimum complexity requirements\nPassword must contain at least one upper case letter, one lower case letter, and one digit", :if => :password_required?
  validates_format_of       :email, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,}\.?)$}
  validates_format_of       :email, :with => %r{[^\.]$}
  validates_uniqueness_of   :email, :case_sensitive => false,
    :message => "address is already being used on another user account.  If you have forgotten your password, please visit the sign in page and click the Forgot password? link."
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, 
    :organization_ids, :organization_membership_requests_attributes, :credentials, 
    :bio, :experience, :employer, :photo_file_name, :photo_content_type, :public, :photo_file_size, :photo_updated_at, 
    :home_phone, :mobile_phone, :phone, :fax, :lock_version, :dashboard_id, :email, :password, :password_confirmation
    
  has_attached_file :photo, :styles => { :medium => "200x200>",  :thumb => "100x100>", :tiny => "50x50>"  }, :default_url => '/assets/missing_:style.jpg'

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def editable_by?(other_user)
    self == other_user || other_user.is_admin_for?(self.jurisdictions)
  end
    
  before_create :generate_oid
  before_create :create_default_email_device
  before_create :set_display_name
  after_create :notify_role_requests

  scope :with_jurisdiction, lambda {|jurisdiction|
    jurisdiction = jurisdiction.is_a?(Jurisdiction) ? jurisdiction : Jurisdiction.find_by_name(jurisdiction)
    { :conditions => [ "role_memberships.jurisdiction_id = ?", jurisdiction.id ], :include => :role_memberships}
  }

  scope :with_user?, lambda {|user|
    { :conditions => ["users.id = ?", user.id]}
  }
  scope :with_apps, lambda{|apps|  #apps is an array of string app names
    { :conditions => ["id in (select user_id from role_memberships where role_id in (select id from roles where application IN (?)))", apps ] }
  }
  scope :without_apps, lambda{|apps|  #apps is an array of string app names
    { :conditions => ["id NOT IN (select user_id from role_memberships where role_id IN (select id from roles where application IN (?)))", apps ] }
  }

#  scope :acknowledged_alert, lamda {|alert|
#	  { :include => :alert_attempts, :conditions => ["alert_attempts.acknowledged_at is not null"] }
#  }

  scope :alphabetical, :order => 'last_name, first_name, display_name'

  # thinking sphinx stuff
  # Should be able to search by first name, last name, display name, email address, phone device, jurisdiction, role, and job title.
  define_index do
    indexes [first_name,last_name,display_name], :as=>:name, :sortable=>true
    indexes first_name,     :sortable => true
    indexes last_name,      :sortable => true
    indexes display_name,   :sortable => true
    indexes email,          :sortable => true
    indexes phone,          :sortable => true
    indexes title,          :sortable => true
    has id,          :as => :user_id
    has roles(:id),         :as => :role_ids
    has "array_to_string(array_agg(DISTINCT CRC32(roles.application)), ',')", :type => :multi, :as => :applications
    has jurisdictions(:id), :as => :jurisdiction_ids
    where                   "deleted_at IS NULL"
    set_property :delta =>  :delayed
  end
    
  def visible_groups
		@_visible_groups ||= (groups | Group.find_all_by_owner_jurisdiction_id_and_scope(jurisdictions.map(&:id), "Jurisdiction") | Group.find_all_by_scope("Global")).sort{|a,b| a.name <=> b.name}
  end

  def organizations
    Organization.with_user(self)
  end

  def is_org_member_of?(other)
    if other.class == Organization
      return true if other.members.include?(self)
    elsif other.class == Array || other.class == ActiveRecord::Relation
      other.each do |org|
        return true if org.members.include?(self)
      end
    end
    false
  end 

  def is_org_admin_for?(other)
    unless other.class == Array || other.class == ActiveRecord::NamedScope::Scope
      other = [ other ]
    end
    other.each do |user|
      return true if !(organizations & user.organizations).empty? && is_admin_for?(user.jurisdictions)
      user.organization_membership_requests.each { |org_mem_request|
        return true if org_mem_request.organization.users.include?(self) && is_admin_for?(user.jurisdictions)
      }
    end
    false
  end

  def is_alerter_for?(jurisdiction)
    jurisdiction.alerting_users.include?(self)
  end

  alias_attribute :name, :display_name
  
  def alerter_jurisdictions
    role_memberships.alerter.map(&:jurisdiction)
  end

  def phin_oid=(val)
    raise "PHIN oids should never change"
  end
  
  def has_uploaded?
    filename = "#{Rails.root.to_s}/message_recordings/tmp/#{confirmation_token}.wav"
    return File.exists?(filename)
  end

  def to_dsml(builder=nil)
    builder=::Builder::XmlMarkup.new( :indent => 2) if builder.nil?
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
 
  def formatted_email
    "#{name} <#{email}>"
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
#    filename = "#{Rails.root.to_s}/message_recordings/tmp/#{self.token}.wav"
#    if File.exists?(filename)
#      File.delete(filename)
#    end
#    self.token = ActiveSupport::SecureRandom.hex
#    self.token_expires_at = Time.zone.now+10.minutes
#    self.save
#    return self.token
  end

  def viewable_groups
    Group.joins("JOIN users owner on owner.id = owner_id").where("owner.id = ? OR (scope = 'Jurisdiction' AND owner_jurisdiction_id in (?)) OR scope = 'Global'", id, jurisdictions.map(&:id))
  end

  # def delete_by(requester_email,requester_ip)
    # # This logical deleting works jointly with the default_scope :conditions => {:deleted_at => nil}
    # begin
      # User.transaction do
        # self.deleted_by = requester_email   # email addr of the deleter - redundant with paper_trail
        # self.deleted_from = requester_ip    # ip addr of the deleter
        # self.deleted_at = Time.now.utc      # redundant with paper_trail
        # self.save!
      # end
    # rescue
      # errors.add(:base, "Failure during deleting the user with the email of #{self.email}.")
    # end
    # if User.find_by_id(self.id)
      # errors.add(:base, "Unexpectectly the user with the email of #{self.email} has not been deleted.")
    # end
  # end
# 
  # def delayed_delete_by(requester_email,requester_ip)
    # begin
      # self.send_later(:delete_by,requester_email,requester_ip)
      # unless errors.empty?
        # AppMailer.user_delete_error(requester_email, "Could not delete the user with the email of #{self.email}.").deliver
      # end 
    # end
  # end

  def self.find_deleted(user_id)
    deleted_user = Version.find_by_item_id_and_item_type_and_event(user_id, 'User', 'destroy') # look for a deleted version of User in paper_trail
    if deleted_user.nil?
      raise ActiveRecord::RecordNotFound , "Couldn't find User with ID=#{user_id}"
    else
      return deleted_user.reify
    end
  end

  def to_iphone_results
    rm = role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}.sort[0..1]
    {'header'=> {'first_name'=>first_name, 'last_name'=>last_name},
      'preview'=> {'pair'=>[{'key'=>email},{'key'=>rm[0]},{'key'=>rm[1]}]},
      'phone' => [{'officePhone'=>phone},{'mobilePhone'=>mobile_phone}]
    }
  end

  def to_json_results(for_admin=false)
    rm = role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}
    rq = (for_admin) ? role_requests.unapproved.map{|rq| "#{rq.role.name} in #{rq.jurisdiction.name}"} : []
    {
      'user_id' => id, 'display_name' => display_name, 'first_name'=>first_name, 'last_name'=>last_name,
      'email'=>email, 'role_memberships'=>rm, 'role_requests'=>rq, 'photo' => photo.url(:tiny)
    }
  end

  def to_json_profile
    roles = role_memberships.collect{ |rm| {"role" => rm.role.name, "jurisdiction" => rm.jurisdiction.name} }
    orgs = organizations.collect{ |o| {"name" => o.name, "id" => o.id} }
    device_defuddler = {"Device::EmailDevice" => "email", "Device::BlackberryDevice" => "blackberry", "Device::PhoneDevice" => "phone", "Device::SmsDevice" => "sms"}
  # devs = devices.collect{ |d| {"type" => device_defuddler[d].type], "address" => d.options.values.first} }
    {
      'user_id' => id, 'display_name' => display_name, 'first_name' => first_name, 'last_name' => last_name,
      'contacts' => [{"type" => "email", 'address' => email},
                     {"type" => "office_phone", 'address'  => phone},
                     {"type" => "home_phone", 'address' =>  home_phone},
                     {"type" => "mobile_phone", 'address' => mobile_phone},
                     {"type" => "fax", 'address' => fax }],
      'occupation' => title, 'bio' => bio, 'credentials' => credentials, 'experience' => experience,
      'employer' => employer, 'job_description' => description,
      'role_memberships'=>roles, 'organizations' => orgs,
  #   'devices' => devs, 
      'photo' => photo.url(:medium)
    }
  end

  def to_json_private_profile
    roles = role_memberships.collect{ |rm| {"role" => rm.role.name, "jurisdiction" => rm.jurisdiction.name} }
    orgs = organizations.collect{ |o| {"name" => o.name, "id" => o.id} }
    { 'user_id' => id, 'display_name' => display_name, 'first_name' => first_name, 'last_name' => last_name,
      'contacts' => [{"type" => "email", 'address' => email}],
      'role_memberships'=>roles, 'organizations' => orgs, 'photo' => photo.url(:medium)
    }
  end

  def to_json_edit_profile
    role_desc = role_memberships.collect { |rm|
      {:id => rm.id, :role_id => rm.role_id, :rname => Role.find(rm.role_id).to_s, :type => "role", :state => "unchanged",
      :jurisdiction_id => rm.jurisdiction_id, :jname => Jurisdiction.find(rm.jurisdiction_id).to_s }
    }
    role_requests.unapproved.each { |rq|
      rq = {:id => rq.id, :role_id => rq.role_id, :rname => Role.find(rq.role_id).to_s, :type => "req", :state => "pending",
            :jurisdiction_id => rq.jurisdiction_id, :jname => Jurisdiction.find(rq.jurisdiction_id).to_s }
      role_desc.push(rq)
    }
    device_desc = devices.collect { |d|
      type, value = d.to_s.split(": ")
      {:id => d.id, :type => type, :rbclass => d.class.to_s, :value => value, :state => "unchanged"}
    }
    org_desc = organizations.collect { |o|
      {:id => o.id, :org_id => o.id, :name => o.name, :desc => o.description, :type => "org", :state => "unchanged"}
    }
    organization_membership_requests.unapproved.each { |rq|
      o = Organization.find(rq.organization_id)
      org_desc.push({:id => rq.id, :org_id => rq.organization_id, :name => o.name, :desc => o.description, :type => "req", :state => "pending"})
    }
    extra = {:current_photo => photo.url(:medium), :devices => device_desc, :role_desc => role_desc, :org_desc => org_desc}
     {:user => self, :extra => extra}
  end

  def update_devices(device_list_json, current_user)
    return [ false, [ "Permission denied" ] ] unless editable_by?(current_user)
    device_list = ActiveSupport::JSON.decode(device_list_json)
    success = true
    device_errors = []

    # Device: class to attr_name map
    deviceOptionMap = {
      'Device::EmailDevice' =>      'email_address',
      'Device::PhoneDevice' =>      'phone',
      'Device::SmsDevice' =>        'sms',
      'Device::FaxDevice' =>        'fax',
      'Device::BlackberryDevice' => 'blackberry'
    }
    device_list.find_all{|d| d["state"]=="deleted" && d["id"] > 0}.each { |d|
      device_to_delete = Device.find(d["id"])
      device_to_delete.destroy
    }
    device_list.find_all{|d| d["state"]=="new"}.each { |d|
      attr_name = deviceOptionMap[d["rbclass"]]
      new_device = d["rbclass"].constantize.new({attr_name => d["value"]})
      new_device.user = self
      if !new_device.save
        success = false
        device_errors.concat(new_device.errors.full_messages)
      end
    }

    [ success, device_errors ]
  end

  def handle_org_requests(req_json, current_user)
    return [ false, [ "Permission denied" ] ] unless editable_by?(current_user)
    rq_list = ActiveSupport::JSON.decode(req_json)
    result = "success"
    rq_errors = []

    rq_list.find_all{|rq| rq["state"]=="deleted" && rq["id"] > 0}.each { |rq|
      if rq["type"]=="req"
        rq_to_delete = OrganizationMembershipRequest.find(rq["id"])
        if rq_to_delete && self == rq_to_delete.user
          rq_to_delete.destroy
        else
          rq_errors.concat(rq_to_delete.errors.full_messages)
        end
      else
        org = Organization.find(rq["id"])
        org.delete(self)
        orig_request = OrganizationMembershipRequest.find_by_organization_id_and_user_id(org.id, self.id)
        orig_request.destroy if orig_request
        if !org.save
          result = "failure"
          rq_errors.concat(org.errors.full_messages)
        end
      end
    }
    rq_list.find_all{|rq| rq["state"]=="new"}.each { |rq|
      org_request = OrganizationMembershipRequest.new
      org_request.organization_id = rq["org_id"]
      org_request.requester = current_user
      org_request.user = self
      unless org_request.save && org_request.valid?
        result = "failure"
        rq_errors.concat(org_request.errors.full_messages)
      end
    }

    [ result, rq_errors ]
  end

  def to_s
    display_name    
  end

  def within_jurisdictions
    jurs=jurisdictions.sort_by(&:lft)
    jurs=jurs.map{|j1| jurs.detect{|j2| j2.is_ancestor_of?(j1)} || j1}.uniq
    return "" if jurs.empty?
    ors=jurs.map{|j| "(jurisdictions.lft >= #{j.lft} AND jurisdictions.lft <= #{j.rgt})"}.join(" OR ")
  end

  def confirm_email!
    unless email_confirmed?
      role_requests.unapproved.each(&:notify_admin_of_request)

      organization_membership_requests.each do |omr|
        if omr.has_invitation?
          invitation = Invitation.find_last_by_organization_id(omr.organization_id)
          omr.approve!(invitation.author)
        end
      end
    end
    #super
  end

private

  def notify_role_requests
    role_requests.unapproved.each(&:notify_admin_of_request)
  end

  def generate_oid
    self[:phin_oid] = email.to_phin_oid
  end
  
  def create_default_email_device
    email = (Device::EmailDevice.new :email_address => self.email)
    devices << email
  end
    
  def set_display_name
    self.display_name = "#{self.first_name.strip} #{self.last_name.strip}" if self.display_name.nil? || self.display_name.strip.blank?
  end

end
