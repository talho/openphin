class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => "cn", :prefix => "ou=Groups", :classes => ['top', 'groupofuniquenames']
  has_many :users, :class_name => "User", :wrap => "uniqueMember", :primary_key => "dn"
end
