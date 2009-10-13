class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.integer :owner_id
      t.string :scope
      t.timestamps
    end

    create_table :groups_jurisdictions, :id => false do |t|
      t.integer :group_id
      t.integer :jurisdiction_id
    end

    create_table :groups_roles, :id => false do |t|
      t.integer :group_id
      t.integer :role_id
    end

    create_table :groups_users, :id => false do |t|
      t.integer :group_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :groups_users
    drop_table :groups_roles
    drop_table :groups_jurisdictions
    drop_table :groups
  end
end
