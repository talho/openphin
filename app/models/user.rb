# Required Attributes: :cn, :sn, :organizations

class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :role_memberships
  has_and_belongs_to_many :organizations
  has_many :jurisdictions, :through => :role_memberships 
  has_many :roles, :through => :role_memberships
  has_one :profile, :class_name => "UserProfile"

  validates_uniqueness_of :email
  validates_presence_of :email
  
  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title
  
  before_create :generate_oid
  
  def name
    first_name + " " + last_name
  end
  
  #def auto_complete_for_user_display_name
  #  User.find(:display_name => params[:user][:display_name])
  #end

  #def auto_complete_for_user_first_name
    
  #end
  
  #def auto_complete_for_user_last_name
    
  #end
  
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

private

  def generate_oid
    self[:phin_oid] = email.to_phin_oid
  end

end
