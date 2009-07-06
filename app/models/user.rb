class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => "cn", :prefix => "ou=People", :classes => ['top', 'inetorgperson']
  has_many :groups, :class_name => "Group", :wrap => "memberof", :primary_key => "uniqueMember"
end
