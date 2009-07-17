# == Schema Information
#
# Table name: jurisdictions
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  phin_oid               :string(255)
#  description            :string(255)
#  fax                    :string(255)
#  locality               :string(255)
#  postal_code            :string(255)
#  state                  :string(255)
#  street                 :string(255)
#  phone                  :string(255)
#  county                 :string(255)
#  alerting_jurisdictions :string(255)
#  parent_id              :integer
#  lft                    :integer
#  rgt                    :integer
#  created_at             :datetime
#  updated_at             :datetime
#  fips_code              :string(255)
#

class Jurisdiction < ActiveRecord::Base
  acts_as_nested_set
  
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  has_many :role_requests

  validates_uniqueness_of :name
  
  def admins
    users.with_role(Role.admin)
  end

  def parent
    Jurisdiction.find(parent_id) unless !Jurisdiction.exists?(parent_id)
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
