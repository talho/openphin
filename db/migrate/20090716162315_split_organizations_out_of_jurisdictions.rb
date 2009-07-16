class SplitOrganizationsOutOfJurisdictions < ActiveRecord::Migration
  class Jurisdiction < ActiveRecord::Base
  end
  
  class Organization < ActiveRecord::Base
  end
  
  def self.up
    create_table :organizations, :force => true do |t|
       t.string   "name"
       t.string   "phin_oid"
       t.string   "description"
       t.string   "fax"
       t.string   "locality"
       t.string   "postal_code"
       t.string   "state"
       t.string   "street"
       t.string   "phone"
       t.string   "county"
       t.string   "alerting_jurisdictions"
       t.string   "primary_organization_type"
       t.string   "type"
       t.datetime "created_at"
       t.datetime "updated_at"
       t.boolean  "foreign"
       t.string   "queue"
     end
     
     fields = [:name, :phin_oid, :description, :fax, :locality, :postal_code, :state, :street, :phone, :county, :alerting_jurisdictions, :primary_organization_type, :type, :created_at, :updated_at, :foreign, :queue]
     
     Jurisdiction.find_all_by_type('Organization').each do |old|
       new_org = Organization.new
       fields.each do |field|
         new_org.send("#{field}=", old.send(field))
       end
     end
     
     change_table :jurisdictions do |t|
       t.remove :foreign
       t.remove :primary_organization_type
       t.remove :queue
       t.remove :type
     end
  end

  def self.down
    change_table :jurisdictions do |t|
       t.boolean :foreign
       t.string :primary_organization_type
       t.string :queue
       t.string :type
     end
    
    Organization.all.each do |old|
       new_org = Jurisdiction.new(:type => 'Organization')
       fields.each do |field|
         new_org.send("#{field}=", old.send(field))
       end
     end
    
    drop_table :organizations
  end
end
