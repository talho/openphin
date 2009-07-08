class CreatePhinRoles < ActiveRecord::Migration
  def self.up
    create_table :phin_roles do |t|
      t.string :name
      t.string :description
      t.string(:phin_oid)   
      t.timestamps
    end
  end

  def self.down
    drop_table :phin_roles
  end
end
