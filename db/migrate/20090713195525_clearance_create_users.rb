class ClearanceCreateUsers < ActiveRecord::Migration
  def self.up
    change_table(:phin_people) do |t|
      t.string   :encrypted_password, :limit => 128
      t.string   :salt,               :limit => 128
      t.string   :token,              :limit => 128
      t.datetime :token_expires_at
      t.boolean  :email_confirmed, :default => false, :null => false
    end

    add_index :phin_people, [:id, :token]
    add_index :phin_people, :email
    add_index :phin_people, :token
  end

  def self.down
    change_table :phin_people do |t|
      t.remove :encrypted_password, :salt, :token, :token_expires_at, :email_confirmed
    end
    
    drop_index :phin_people, :email
  end
end
