class PhinRole < ActiveLdap::Base
  ldap_mapping :dn_attribute => "cn", :prefix => "ou=Roles", :classes => ['PhinRole']
  has_many :phinpeople, :class_name => "PhinPerson", :foreign_key => "uniqueMember", :primary_key => "dn"
end
