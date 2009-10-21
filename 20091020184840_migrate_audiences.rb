class MigrateAudiences < ActiveRecord::Migration
  class Alert < ActiveRecord::Base
    has_and_belongs_to_many :jurisdictions, :class_name => 'MigrateAudiences::Jurisdiction'
    has_and_belongs_to_many :organizations, :class_name => 'MigrateAudiences::Organization'
    has_and_belongs_to_many :roles, :class_name => 'MigrateAudiences::Role'
    has_and_belongs_to_many :users, :class_name => 'MigrateAudiences::User'
    
    has_many :targets, :as => :item, :class_name => 'MigrateAudiences::Target'
    has_many :audiences, :through => :targets, :class_name => 'MigrateAudiences::Audience'
  end
  class Jurisdiction < ActiveRecord::Base
  end
  class User < ActiveRecord::Base
  end
  class Organization < ActiveRecord::Base
  end
  class Target < ActiveRecord::Base
    belongs_to :item, :polymorphic => true
    belongs_to :audience, :class_name => 'MigrateAudiences::Target'
  end
  
  def self.up
    Alert.all.each do |alert|
      alert.audiences.create!(
        :jurisdictions => alert.jurisdictions,
        :roles         => alert.roles,
        :users         => alert.users
      )
    end
    # drop_table :alerts_jurisdictions
    # drop_table :alerts_organizations
    # drop_table :alerts_roles
    # drop_table :alerts_users
  end

  def self.down
    # create_table "alerts_users", :id => false, :force => true do |t|
    #   t.integer "alert_id"
    #   t.integer "user_id"
    # end
    # 
    # create_table "alerts_roles", :id => false, :force => true do |t|
    #   t.integer "alert_id"
    #   t.integer "role_id"
    # end
    # 
    # create_table "alerts_organizations", :id => false, :force => true do |t|
    #   t.integer "alert_id"
    #   t.integer "organization_id"
    # end
    # 
    # create_table "alerts_jurisdictions", :id => false, :force => true do |t|
    #   t.integer "alert_id"
    #   t.integer "jurisdiction_id"
    # end
    
    Alert.all.each do |alert|
      audience = alert.audiences.first
      alert.jurisdictions = audience.jurisdictions
      alert.roles         = audience.roles
      alert.users         = audience.users
    end
  end
end
