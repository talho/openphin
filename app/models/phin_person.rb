# Required Attributes: :cn, :sn, :organizations

class PhinPerson < ActiveLdap::Base
  #TODO test for presence of classes
  ldap_mapping :dn_attribute => "externalUID", :prefix => "ou=People", :classes => ['PhinPerson','inetUser']
  has_many :phin_organizations, :class_name => "PhinOrganization", :foreign_key => "memberOf", :primary_key => "dn"
  has_many :phin_jurisdictions, :class_name => "PhinJurisdiction", :foreign_key => "memberOf", :primary_key => "dn"
  has_many :phin_roles, :class_name => "PhinRole", :foreign_key => "memberOf", :primary_key => "dn"

  def validate_on_create
    if externalUID.nil?
      errors.add(:externalUID, "externalUID cannot be blank")
    end
  end
  validates_format_of :externalUID, :with => /\A(#{PHIN_OID_ROOT})+(.\d)/, :on => :create, :message => "externalUID not well formed"
  validates_format_of :dn, :with => /\A(externalUID=#{PHIN_OID_ROOT}+(.\d))(,#{base})\Z/, :on => :create, :message => "dn not well formed"

  def alertdevices
    ActiveLdap::Base.search(:base => dn, :filter => '(objectclass=alertCommunicationDevice)', :scope => :one, :attributes => ['cn']).map{|subcn| Device.find(:first, subcn[1]['cn'])}
  end

  def to_xml(builder=nil)
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
