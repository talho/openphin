class PhinJurisdiction < ActiveLdap::Base
  ldap_mapping :dn_attribute => "cn", :prefix => "ou=Jurisdictions", :classes => ['PhinOrganization']
  has_many :phinpeople, :class_name => "PhinPerson", :foreign_key => "uniqueMember", :primary_key => "dn"

  #TODO: document requirement for a prefix to be configured on installation that maps to an ou for jurisdictions 
  def parent
    parent_dn=dn.split(",").drop(1).join(',')
    if parent_dn.split(',').first != prefix
      parent_node=PhinJurisdiction.find(parent_dn)
    else
      nil
    end
  end

  def jurisdictions(deep=true)
    if deep
      #TODO: Restrict :prefix scope to improve performance
      ActiveLdap::Base.search(:base => dn, :filter => '(objectclass=PhinOrganization)', :scope => :sub, :attributes => ['cn']).map{|subcn| 
        PhinJurisdiction.find(:first, subcn[1]['cn']) unless subcn[1]['cn'][0] == cn
      }.compact
    else
      #TODO: Restrict :prefix scope to improve performance
      ActiveLdap::Base.search(:base => dn, :filter => '(objectclass=PhinOrganization)', :scope => :one, :attributes => ['cn']).map{|subcn| PhinJurisdiction.find(:first, subcn[1]['cn'])}
    end
  end


   def to_xml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml(:objectclass) do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "organizationalUnit"
        oc.dsml ocv, "PhinOrganization"
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
      if alertingJurisdictions.is_a?(Array)
        entry.dsml(:attr, :name => :alertingJurisdictions) do |aj|
          alertingJurisdictions.each do |jur|
            aj.dsml(:value, jur)
          end
        end
      else
        entry.dsml(:attr, :name => :alertingJurisdictions) {|a| a.dsml :value, alertingJurisdictions}
      end
    end
  end
end
