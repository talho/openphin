class Device < ActiveLdap::Base
  ldap_mapping :dn_attribute => "cn", :prefix => "ou=People", :classes => ['alertCommunicationDevice']

  def parent
    parent_dn=dn.split(",").drop(1).join(',')
    if parent_dn.split(',').first != prefix
      parent_node=PhinPerson.find(parent_dn)
    else
      nil
    end
  end

  def to_xml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml(:objectclass) do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "organizationalUnit"
        oc.dsml ocv, "AlertCommunicationDevice"
      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, cn}
      entry.dsml(:attr, :name => :description) {|a| a.dsml :value, description}
      entry.dsml(:attr, :name => :deviceName) {|a| a.dsml :value, deviceName}
      entry.dsml(:attr, :name => :deviceType) {|a| a.dsml :value, deviceType}
      entry.dsml(:attr, :name => :coverage) {|a| a.dsml :value, coverage}
      entry.dsml(:attr, :name => :emailAddress) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :areaCode) {|a| a.dsml :value, areaCode}
      entry.dsml(:attr, :name => :exchnage) {|a| a.dsml :value, exchange}
      entry.dsml(:attr, :name => :line) {|a| a.dsml :value, line}
      entry.dsml(:attr, :name => :rank) {|a| a.dsml :value, rank}
      entry.dsml(:attr, :name => :pin) {|a| a.dsml :value, pin}
      entry.dsml(:attr, :name => :countryPrefix) {|a| a.dsml :value, countryPrefix}
      entry.dsml(:attr, :name => :internationalNumber) {|a| a.dsml :value, internationalNumber}
      entry.dsml(:attr, :name => :emergencyUseInd) {|a| a.dsml :value, emergencyUseInd}
      entry.dsml(:attr, :name => :homeInd) {|a| a.dsml :value, homeInd}
    end
  end
end


