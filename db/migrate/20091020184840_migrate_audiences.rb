# This migration converts the old Alert audience specs to the new Audience model
class MigrateAudiences < ActiveRecord::Migration
  ActiveRecord::Base.store_full_sti_class = false
  
  class Alert < ActiveRecord::Base
    has_and_belongs_to_many :jurisdictions, :class_name => 'MigrateAudiences::Jurisdiction'
    has_and_belongs_to_many :roles, :class_name => 'MigrateAudiences::Role'
    has_and_belongs_to_many :users, :class_name => 'MigrateAudiences::User'
    has_many :group_snapshots, :class_name => 'MigrateAudiences::GroupSnapshot'
    has_many :groups, :through => :group_snapshots, :class_name => 'MigrateAudiences::Group'
    
    has_many :targets, :as => :item, :class_name => 'MigrateAudiences::Target'
    has_many :audiences, :through => :targets, :class_name => 'MigrateAudiences::Audience'
    
    def self.name
      'Alert'
    end
  end
  class GroupSnapshot < ActiveRecord::Base
    belongs_to :alert, :class_name => 'MigrateAudiences::Alert'
    belongs_to :group, :foreign_key => 'audience_id', :class_name => 'MigrateAudiences::Audience'
    has_and_belongs_to_many :users, :class_name => 'MigrateAudiences::User'
  end
  
  class Jurisdiction < ActiveRecord::Base
  end
  
  class User < ActiveRecord::Base
  end
  
  class Target < ActiveRecord::Base
    belongs_to :item, :polymorphic => true
    belongs_to :audience, :class_name => 'MigrateAudiences::Audience'
    has_and_belongs_to_many :users, :class_name => 'MigrateAudiences::User'
  end

  class Audience < ActiveRecord::Base
    has_and_belongs_to_many :jurisdictions, :class_name => 'MigrateAudiences::Jurisdiction'
    has_and_belongs_to_many :roles, :class_name => 'MigrateAudiences::Role'
    has_and_belongs_to_many :users, :class_name => 'MigrateAudiences::User'
  end

  class Group < Audience
    has_many :group_snapshots, :class_name => 'MigrateAudiences::GroupSnapshot'
    has_many :alerts, :through => :group_snapshots, :class_name => 'MigrateAudiences::Alert'
  end
  
  def self.up
    create_table :targets_users, :id => false, :force => true do |t|
      t.integer :user_id, :target_id
    end
    # Alert.all.each do |alert|
      # unless alert.jurisdictions.empty? && alert.roles.empty? && alert.users.empty?
        # alert.audiences.create!(
          # :jurisdictions => alert.jurisdictions,
          # :roles         => alert.roles,
          # :users         => alert.users
        # )
      # end
      # alert.group_snapshots.each do |group_snapshot|
        # alert.targets.create! :audience_id => group_snapshot.group, :users => group_snapshot.users
      # end
    # end
    drop_table :alerts_jurisdictions
    drop_table :alerts_organizations
    drop_table :alerts_roles
    drop_table :alerts_users
    drop_table :group_snapshots_users
    drop_table :group_snapshots
  end

  def self.down
    create_table "group_snapshots", :force => true do |t|
      t.integer  "audience_id"
      t.integer  "alert_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "group_snapshots_users", :id => false, :force => true do |t|
      t.integer "group_snapshot_id"
      t.integer "user_id"
    end
    create_table "alerts_users", :id => false, :force => true do |t|
      t.integer "alert_id"
      t.integer "user_id"
    end
    
    create_table "alerts_roles", :id => false, :force => true do |t|
      t.integer "alert_id"
      t.integer "role_id"
    end
    
    create_table "alerts_organizations", :id => false, :force => true do |t|
      t.integer "alert_id"
      t.integer "organization_id"
    end
    create_table "alerts_jurisdictions", :id => false, :force => true do |t|
      t.integer "alert_id"
      t.integer "jurisdiction_id"
    end
    
    # Alert.all.each do |alert|
      # alert.targets.each do |target|
        # if target.audience.is_a?(Group)
          # alert.group_snapshots.create! :group => target.audience, :users => target.users
        # else
          # alert.jurisdictions += target.audience.jurisdictions
          # alert.roles         += target.audience.roles
          # alert.users         += target.audience.users
        # end
      # end
    # end

    drop_table :targets_users
  end
end
