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
  has_many :alert_attempts
  has_many :deliveries, :through => :alert_attempts
  belongs_to :contact, :class_name => "User"
  has_many :organization_requests, :dependent => :destroy
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  validates_presence_of :phone, :postal_code, :distribution_email, :street, :state 
  def validate
    errors.add_to_base("Organization name can't be blank") if self.name.blank?
    errors.add_to_base("Description of organization can't be blank") if self.description.blank?
    errors.add_to_base("City can't be blank") if self.locality.blank?
  end
  
  before_create :set_token, :create_group

  default_scope :order => :name
  
  named_scope :approved, :include => :organization_requests, :conditions => [ 'organization_requests.approved = ?', true ]
  named_scope :unapproved, :include => :organization_requests, :conditions => ["organization_requests.approved is null or organization_requests.approved = ?" , false ]
  named_scope :requests_in_jurisdictions, lambda { |jurs|
    { :include => 'organization_requests',
      :conditions => [ 'organization_requests.jurisdiction_id IN (?)', jurs.map(&:id) ]
    }
  }
  named_scope :with_user, lambda {|user|
    { :conditions => ["audiences.id = organizations.group_id AND  (audiences.type = 'Group' ) AND audiences.id = audiences_users.audience_id AND audiences_users.user_id = users.id AND (users.id = ?)", user.id], :joins => ", audiences, audiences_users, users", :order => 'organizations.name'}
  }
  named_scope :foreign, :conditions => ["organizations.foreign = true"]
  named_scope :non_foreign, :conditions => ["organizations.foreign = false"]

  validates_inclusion_of :foreign, :in => [true, false]

  def members(options={})
    group.users.scoped options
  end
  
  def <<(user)
    group.users << user unless group.users.include?(user)
  end

  def delete(user)
    group.users.delete(user)
  end

  def approved?
    organization_requests.any?(&:approved)
  end

  def to_dsml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
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
    self.token = ActiveSupport::SecureRandom.hex
  end
  
  def create_group
    self.group = Group.create!(:scope => "Organization", :name => self.name)
  end
end
