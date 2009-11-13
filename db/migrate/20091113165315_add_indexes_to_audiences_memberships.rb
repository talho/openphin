class AddIndexesToAudiencesMemberships < ActiveRecord::Migration
  def self.up
    add_index :audiences_roles, :audience_id
    add_index :audiences_roles, :role_id
    add_index :audiences_jurisdictions, :audience_id
    add_index :audiences_jurisdictions, :jurisdiction_id
    add_index :audiences_users, :audience_id
    add_index :audiences_users, :user_id
  end

  def self.down
    remove_index :audiences_roles, :audience_id
    remove_index :audiences_roles, :role_id
    remove_index :audiences_jurisdictions, :audience_id
    remove_index :audiences_jurisdictions, :jurisdiction_id
    remove_index :audiences_users, :audience_id
    remove_index :audiences_users, :user_id
  end
end
