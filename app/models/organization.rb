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
#  foreign                   :boolean(1)
#  queue                     :string(255)
#  organization_type_id      :integer(4)
#  distribution_email        :string(255)
#  contact_id                :integer(4)
#  approved                  :boolean(1)
#  contact_display_name      :string(255)
#  contact_phone             :string(255)
#  contact_email             :string(255)
#

class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :jurisdictions
  has_many :alert_attempts
  has_many :deliveries, :through => :alert_attempts
  belongs_to :organization_type
  has_one :contact, :class_name => "User", :primary_key => :contact_email, :foreign_key => 'email'
  
  default_scope :order => :name
  
  named_scope :approved, :conditions => { :approved => true }
  named_scope :unapproved, :conditions => ["approved is null or approved = ?" , false ]

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
  
  def deliver(alert)
    raise 'not foreign' unless foreign?
    cascade_alert = CascadeAlert.new(alert)
    File.open(File.join(phin_ms_queue, "#{cascade_alert.distribution_id}.edxl"), 'w') {|f| f.write cascade_alert.to_edxl }
  end
  
  def email
    distribution_email
  end
  
  def phin_ms_queue
    FileUtils.mkdir_p File.join(Agency[:phin_ms_base_path], queue)
  end
end
