class CreatePhinPeople < ActiveRecord::Migration
  def self.up
    create_table :phin_people do |t|
      t.column :last_name, :string
      t.column :phin_oid, :string
      t.column :description, :text
      t.column :display_name, :string
      t.column :first_name, :string
      t.column :email, :string
      t.column :preferred_language, :string
      t.column :title, :string
      #roles: has_many 
      t.timestamps
    end
  end

  def self.down
    drop_table :phin_people
  end
end
