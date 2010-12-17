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
  extend Clearance::User::ClassMethods
  include Clearance::User::InstanceMethods
  include Clearance::User::AttrAccessible
  include Clearance::User::AttrAccessor
  include Clearance::User::Callbacks
  
  UNDELETED = {:deleted_at => nil}
  default_scope :conditions => UNDELETED

  has_many :devices, :dependent => :delete_all
  accepts_nested_attributes_for :devices
  
  has_many :role_memberships, :include => [:jurisdiction, :role], :dependent => :delete_all
  has_many :role_requests, :dependent => :delete_all, :include => [:jurisdiction, :role]
  has_many :organization_membership_requests, :dependent => :delete_all
  accepts_nested_attributes_for :role_requests, :organization_membership_requests

  has_many :jurisdictions, :through => :role_memberships, :uniq => true
  has_many :roles, :through => :role_memberships, :uniq => true 
  has_many :alerting_jurisdictions, :through => :role_memberships, :source => 'jurisdiction', :include => {:role_memberships => [:role, :jurisdiction]}, :conditions => ['roles.alerter = ?', true]
  has_many :alerts, :foreign_key => 'author_id', :include => [:audiences, :alert_device_types, :from_jurisdiction, :original_alert, :author]
  has_many :alert_attempts, :include => [:jurisdiction, :organization, :alert, :user, :acknowledged_alert_device_type, :devices]
  has_many :deliveries,    :through => :alert_attempts
  has_many :recent_alerts, :through => :alert_attempts, :source => 'alert', :include => [:alert_device_types, :from_jurisdiction, :original_alert, :author], :order => "alerts.created_at DESC"
#  has_many :viewable_alerts, :through => :alert_attempts, :source => "alert", :order => "alerts.created_at DESC"
  has_many :groups, :foreign_key => "owner_id", :source => "user"

  has_many :documents, :foreign_key => 'owner_id' do
    def inbox
      scoped :conditions => 'documents.folder_id IS NULL'
    end      
    def expiring_soon(options = {})
      options[:conditions] = Document.merge_conditions(options[:conditions], ["created_at <= ? and created_at > ?", 25.days.ago, 26.days.ago])
      scoped(options)
    end
  end
  has_many :folders  do
    def rootsm
      scoped :conditions => 'folders.parent_id IS NULL'
    end
  end

  #has_many :subscriptions
  #has_many :shares, :through => :subscriptions
  has_many :folder_permissions
  has_many :authoring_folders, :through => :folder_permissions, :source => :folder, :conditions => ['folder_permissions.permission = 1']
  has_many :admin_folders, :through => :folder_permissions, :source => :folder, :conditions => ['folder_permissions.permission = 2']
  has_and_belongs_to_many :audiences, :join_table => 'audiences_recipients'

  def shares
    Folder.scoped :joins => ', audiences_recipients', :conditions => ['audiences_recipients.audience_id = folders.audience_id and audiences_recipients.user_id = ? and folders.user_id != ?', self.id, self.id], :include => [:owner, :folder_permissions]
  end

  def shared_documents
    Document.scoped :joins => ', folders, audiences_recipients', :conditions => ['audiences_recipients.audience_id = folders.audience_id and audiences_recipients.user_id = ? and folders.user_id != ? and documents.folder_id = folders.id', self.id, self.id], :include => [:owner]
  end

  has_many :favorites


  validates_presence_of     :email
  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_length_of       :password, :minimum => 6, :too_short => "must be at least 6 characters long", :if => :password_required?
  validates_format_of       :password, :with => /(?=[-_a-zA-Z0-9]*?[A-Z])(?=[-_a-zA-Z0-9]*?[a-z])(?=[-_a-zA-Z0-9]*?[0-9])[-_a-zA-Z0-9]/, :message => "does not meet minimum complexity requirements\nPassword must contain at least one upper case letter, one lower case letter, and one digit", :if => :password_required?
  validates_format_of       :email, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,}\.?)$}
  validates_format_of       :email, :with => %r{[^\.]$}
  validates_uniqueness_of   :email, :case_sensitive => false, :scope => [:deleted_at],
    :message => "address is already being used on another user account.  If you have forgotten your password, please visit the sign in page and click the Forgot password? link."
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_associated :role_requests
  validates_associated :role_memberships

  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, 
    :organization_ids, :role_requests_attributes, :organization_membership_requests_attributes, :credentials, 
    :bio, :experience, :employer, :photo_file_name, :photo_content_type, :public, :photo_file_size, :photo_updated_at, 
    :home_phone, :mobile_phone, :phone, :fax, :lock_version
    
  has_attached_file :photo, :styles => { :medium => "200x200>",  :thumb => "100x100>", :tiny => "50x50>"  }, :default_url => '/images/missing_:style.jpg'

  def editable_by?(other_user)
    self == other_user || jurisdictions.any?{|j| other_user.is_admin_for?(j) }
  end
    
  before_create :generate_oid
  before_create :set_confirmation_token
  before_create :create_default_email_device
  before_create :set_display_name

  after_create :assign_public_role

  named_scope :live, :conditions => UNDELETED
  
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
  
  named_scope :with_user?, lambda {|user|
    { :conditions => ["users.id = ?", user.id]}
  }

#  named_scope :acknowledged_alert, lamda {|alert|
#	  { :include => :alert_attempts, :conditions => ["alert_attempts.acknowledged_at is not null"] }
#  }
  
  named_scope :alphabetical, :order => 'last_name, first_name, display_name'

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
    has roles(:id),         :as => :role_ids
    has jurisdictions(:id), :as => :jurisdiction_ids
    where                   "deleted_at IS NULL"
    set_property :delta =>  :delayed
  end  
  sphinx_scope(:ts_live) {{ :conditions => UNDELETED }}
  
  def visible_groups
		@_visible_groups ||= (groups | Group.find_all_by_owner_jurisdiction_id_and_scope(jurisdictions.map(&:id), "Jurisdiction") | Group.find_all_by_scope("Global")).sort{|a,b| a.name <=> b.name}
  end

  def organizations
    Organization.with_user(self)
  end

  def self.assign_role(role, jurisdiction, users)
    users.each do |u|
      u.role_memberships.create(:role => role, :jurisdiction => jurisdiction) unless u.role_memberships.map(&:role_id).include?(role.id) && u.role_memberships.map(&:jurisdiction_id).include?(jurisdiction.id)
    end
  end

  def is_admin_for?(other)
    return true if roles.include?(Role.superadmin)
    if other.class == Jurisdiction
      return true if role_memberships.detect{|r| r.role==Role.admin && other.is_or_is_descendant_of?(r.jurisdiction)}
    elsif other.class == Array || other.class == ActiveRecord::NamedScope::Scope
      other.each do |jurisdiction|
        return true if role_memberships.detect{|r| r.role==Role.admin && jurisdiction.is_or_is_descendant_of?(r.jurisdiction)}
      end
    end
    false
  end

  def is_org_member_of?(other)
    if other.class == Organization
      return true if other.members.include?(self)
    elsif other.class == Array || other.class == ActiveRecord::NamedScope::Scope
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
        return true if org_mem_request.organization.members.include?(self) && is_admin_for?(user.jurisdictions)
      }
    end
    false
  end

  def is_alerter_for?(jurisdiction)
    jurisdiction.alerting_users.include?(self)
  end

  def is_super_admin?
    j = Jurisdiction.root.children.first # Should be Texas
    return role_memberships.count(:conditions => ["role_id = ? AND jurisdiction_id = ?", Role.superadmin.id, j.id]) > 0
  end

  def is_admin?
    return role_memberships.count(:conditions => ["role_id = ? OR role_id = ?", Role.admin.id, Role.superadmin.id]) > 0
  end

  def is_org_approver?
    return role_memberships.count(:conditions => ["role_id = ?", Role.org_admin]) > 0
  end
  
  def has_non_public_role?
    self.roles.non_public.size > 0
  end

  def has_public_role?
    self.roles.public.size > 0
  end

  def has_public_role_in?(jurisdiction)
    return role_memberships.count(:conditions => ["role_id = ? AND jurisdiction_id = ?", Role.public.id, j.id]) > 0
  end


  def has_public_role_request?
    return role_requests.count(:conditions => ["role_id = ?", Role.public.id]) > 0
  end

  alias_attribute :name, :display_name
  
  def alerter_jurisdictions
    role_memberships.alerter.map(&:jurisdiction)
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
  
  def alerts_within_jurisdictions(page=nil)
    jurs=alerting_jurisdictions.sort_by(&:lft)
    jurs=jurs.map{|j1| jurs.detect{|j2| j2.is_ancestor_of?(j1)} || j1}.uniq
    return [] if jurs.empty?
    ors=jurs.map{|j| "(jurisdictions.lft >= #{j.lft} AND jurisdictions.lft <= #{j.rgt})"}.join(" OR ")

    Alert.paginate(:conditions => ors,
                   :joins => "inner join jurisdictions on alerts.from_jurisdiction_id=jurisdictions.id",
                   :include => [:original_alert, :cancellation, :author, :from_jurisdiction],
                   :order => "alerts.created_at DESC, alerts.id DESC",
                   :page => page,
                   :per_page => 10)
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
#    filename = "#{RAILS_ROOT}/message_recordings/tmp/#{self.token}.wav"
#    if File.exists?(filename)
#      File.delete(filename)
#    end
#    self.token = ActiveSupport::SecureRandom.hex
#    self.token_expires_at = Time.zone.now+10.minutes
#    self.save
#    return self.token
  end

  def viewable_groups
    groups | Group.jurisdictional.by_jurisdictions(jurisdictions) | Group.global
  end
   
  def delete_by(requester_email,requester_ip)
    # This logical deleting works jointly with the default_scope :conditions => {:deleted_at => nil}
    begin
      User.transaction do
        self.deleted_by = requester_email   # email addr of the deleter
        self.deleted_from = requester_ip    # ip addr of the deleter
        self.deleted_at = Time.now.utc
        self.save!
      end
    rescue
      errors.add_to_base("Failure during deleting the user with the email of #{self.email}.")
    end
    unless User.find_by_id(self.id)
      errors.add_to_base("Unexpectectly the user with the email of #{self.email} has not been deleted.")
    end
  end

  def delayed_delete_by(requester_email,requester_ip)
    begin
      self.send_later(:delete_by,requester_email,requester_ip)
      unless errors.empty?
        AppMailer.deliver_user_delete_error(requester_email, "Could not delete the user with the email of #{self.email}.")
      end 
    end
  end
  
  def moderator_of?(object)
    return is_super_admin? if object == Forum
    return false unless [Forum,Topic].include? object.class
    is_super_admin? || ( object.respond_to?('poster_id') && (self.id == object.poster_id) )
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
    device_defuddler = {"Device::EmailDevice" => "email", "Device::BlackberryDevice" => "blackberry", "Device::PhoneDevice" => "phone", "Device::SMSDevice" => "sms"}
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
    rm_list = is_admin? ? role_memberships.all_roles : role_memberships.user_roles
    role_desc = rm_list.collect { |rm|
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
    return [ false, [ "Permission denied" ] ] unless current_user == self || current_user.is_admin_for?(self.jurisdictions)
    device_list = ActiveSupport::JSON.decode(device_list_json)
    success = true
    device_errors = []

    # Device: class to attr_name map
    deviceOptionMap = {
      'Device::EmailDevice' =>      'email_address',
      'Device::PhoneDevice' =>      'phone',
      'Device::SMSDevice' =>        'sms',
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

  def handle_role_requests(req_json, current_user)
    return [ false, [ "Permission denied" ] ] unless current_user == self || current_user.is_admin_for?(self.jurisdictions)
    rq_list = ActiveSupport::JSON.decode(req_json)
    result = "success"
    rq_errors = []

    ActiveRecord::Base.transaction {
      rq_list.find_all{|rq| rq["state"]=="deleted" && rq["id"] > 0}.each { |rq|
        rqType = (rq["type"]=="req") ? RoleRequest : RoleMembership
        rq_to_delete = rqType.find(rq["id"])
        if rq_to_delete && self == rq_to_delete.user
          rq_to_delete.destroy
        else
          rq_errors.concat(rq_to_delete.errors.full_messages)
        end
      }
      rq_list.find_all{|rq| rq["state"]=="new"}.each { |rq|
        role = Role.find(rq["role_id"])
        role_request = RoleRequest.new
        role_request.jurisdiction_id = rq["jurisdiction_id"]
        role_request.role_id = rq["role_id"]
        role_request.requester = current_user
        role_request.user = self
        if role_request.save && role_request.valid?
          RoleRequestMailer.deliver_user_notification_of_role_request(role_request) if !role_request.approved?
        else
          result = "failure"
          rq_errors.concat(role_request.errors.full_messages)
        end
      }

      if self.role_memberships.public_roles.empty?
        result = "rollback"
        rq_errors.push("You must have at least one public role.  Please add a public role and re-save.")
        raise ActiveRecord::Rollback
      end
    }

    [ result, rq_errors ]
  end

  def handle_org_requests(req_json, current_user)
    return [ false, [ "Permission denied" ] ] unless current_user == self || current_user.is_admin_for?(self.jurisdictions)
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

private

  def assign_public_role
    public_role = Role.public
    if (role_requests.nil? && role_memberships.nil?) || (!role_requests.map(&:role_id).flatten.include?(public_role.id) && !role_memberships.map(&:role_id).flatten.include?(public_role.id))
      if(role_requests.nil? && role_memberships.nil?)
        role_memberships.create!(:role => public_role, :jurisdiction => Jurisdiction.state.first) unless Jurisdiction.state.empty?
      else
        rr = role_requests
        rr.each do |request|
          role_memberships.create!(:role => public_role, :jurisdiction => request.jurisdiction)
          request.destroy if request.role == public_role
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
