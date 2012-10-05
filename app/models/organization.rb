# == Schema Information
#
# Table name: organizations
#
#  id                        :integer(4)      not null, primary key
#  name                      :string(255)
#  phin_oid                  :string(255)
#  description               :string(255)
#  fax                       :string(255)
#  locality                  :string(255)
#  postal_code               :string(255)
#  state                     :string(255)
#  street                    :string(255)
#  phone                     :string(255)
#  alerting_jurisdictions    :string(255)
#  primary_organization_type :string(255)
#  type                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  foreign                   :boolean(1)      default(FALSE), not null
#  queue                     :string(255)
#  distribution_email        :string(255)
#  approved                  :boolean(1)      default(FALSE)
#  token                     :string(128)
#  email_confirmed           :boolean(1)      default(FALSE), not null
#  user_id                   :integer(4)
#  group_id                  :integer(4)
#


class Organization < ActiveRecord::Base

  belongs_to :group
  accepts_nested_attributes_for :group
  
  has_many :alert_attempts
  has_many :deliveries, :through => :alert_attempts
  has_one :folder
  belongs_to :contact, :class_name => "User", :foreign_key => :user_id
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  validates_presence_of :name, :message => "Organization name can't be blank"
  validates_uniqueness_of :name, :message => "organization name must be unique"
  validates_presence_of :description, :message => "Description of organization can't be blank"
  validates_presence_of :locality, :message => "City can't be blank"
  
  before_create :set_token, :create_group
  after_save :ensure_folder
  
  scope :with_user, lambda {|user|
    { :conditions => ["organizations.group_id IN (SELECT * FROM sp_audiences_for_user(?))", user.id], :order => 'organizations.name'}
  }
  scope :foreign, :conditions => ["organizations.foreign = true"]
  scope :non_foreign, :conditions => ["organizations.foreign = false"]

  validates_inclusion_of :foreign, :in => [true, false]

  def users
    group.recipients
  end
  alias :members :users  
  
  def has_user?(user)
    !user.audiences.find(self.id).nil?
  end
  
  def long_description
    "#{self.description}\n#{self.street}\n#{self.locality} #{self.state}, #{self.postal_code}\n#{self.phone}"
  end
  
  def <<(user)
    group.users << user unless group.users.include?(user)
  end

  def delete(user)
    group.users.delete(user)
  end


  def to_dsml(builder=nil)
    builder=::Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml(:objectclass) do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "organizationalUnit"
        oc.dsml ocv, "Organization"
      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, cn}
      entry.dsml(:attr, :name => :externalUID) {|a| a.dsml :value, externalUID}
      entry.dsml(:attr, :name => :description) {|a| a.dsml :value, description}
      entry.dsml(:attr, :name => :fax) {|a| a.dsml :value, facsimileTelephoneNumber}
      entry.dsml(:attr, :name => :l) {|a| a.dsml :value, l}
      entry.dsml(:attr, :name => :postalCode) {|a| a.dsml :value, postalCode}
      entry.dsml(:attr, :name => :st) {|a| a.dsml :value, st}
      entry.dsml(:attr, :name => :street) {|a| a.dsml :value, street}
      entry.dsml(:attr, :name => :telephoneNumber) {|a| a.dsml :value, telephoneNumber}
      entry.dsml(:attr, :name => :primaryOrganizationType) {|pot| pot.dsml :value, primaryOrganizationType}
      entry.dsml(:attr, :name => :county) {|a| a.dsml :value, county}
      # if alertingJurisdictions.is_a?(Array)
      #   entry.dsml(:attr, :name => :alertingJurisdictions) do |aj|
      #     alertingJurisdictions.each do |jur|
      #       aj.dsml(:value, jur)
      #     end
      #   end
      # else
      #   entry.dsml(:attr, :name => :alertingJurisdictions) {|a| a.dsml :value, alertingJurisdictions}
      # end 
    end

  end
  
  def email
    distribution_email
  end
  
  def phin_ms_queue
    FileUtils.mkdir_p File.join(Agency[:phin_ms_base_path], queue)
  end

  def confirmed?
    email_confirmed
  end

  def to_s
    name
  end

  private

  def set_token
    self.token = SecureRandom.hex
  end
  
  def create_group
    self.group = Group.create!(:scope => "Organization", :name => self.name)
  end
    
  # Ensure that there is a folder associated with this organization by
  # 1. Locating the folder by name, if one exists, creating one if not
  # 1. Ensuring that the audience holds the organization's audience and the contact is set as an admin
  def ensure_folder
    self.folder = Folder.new unless self.folder
    
    self.folder.audience = Audience.new if self.folder.audience.nil?
    self.folder.audience.sub_audiences << self.group unless self.folder.audience.sub_audiences.include?(self.group)
    
    self.folder.name = self.name
    
    if self.contact
      self.folder.audience.users << self.contact unless self.folder.audience.user_ids.include?(self.contact.id)
      self.folder.folder_permissions.build(:user_id => self.contact.id, :permission => ::FolderPermission::PERMISSION_TYPES[:admin]) unless self.folder.admins.include?(self.contact)
    end
    
    self.folder.save
    true
  end
end
