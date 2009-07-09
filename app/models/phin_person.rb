# Required Attributes: :cn, :sn, :organizations

class PhinPerson < ActiveRecord::Base
  #TODO test for presence of classes
  has_and_belongs_to_many :phin_organizations
  has_and_belongs_to_many :phin_jurisdictions 
  has_and_belongs_to_many :phin_roles

  validates_uniqueness_of :email
  validates_presence_of :email
  validates_presence_of :phin_oid
  validates_format_of :phin_oid, :with => /\A#{PHIN_OID_ROOT}+[\.\d]+/, :on => :create, :message => " not well formed"
  
  auto_complete_for :display_name, :first_name, :last_name

  def name
    first_name + " " + last_name
  end
  
  #def auto_complete_for_phin_person_display_name
  #  PhinPerson.find(:display_name => params[:phin_person][:display_name])
  #end

  #def auto_complete_for_phin_person_first_name
    
  #end
  
  #def auto_complete_for_phin_person_last_name
    
  #end

  def to_dsml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml:objectclass do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "person"
        oc.dsml ocv, "organizationalPerson"
        oc.dsml ocv, "inetOrgPerson"
        oc.dsml ocv, "PhinPerson"

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

end
