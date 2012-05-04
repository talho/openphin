class ClearanceUpdateUsersTo088 < ActiveRecord::Migration
  class User < ActiveRecord::Base   
    include Clearance::User
  end
  
  def self.up
    change_table(:users) do |t|
      t.string :confirmation_token, :limit => 128
      t.string :remember_token, :limit => 128
    end

    add_index :users, [:id, :confirmation_token]
    add_index :users, :email
    add_index :users, :remember_token
    
    ClearanceUpdateUsersTo088::User.find_each do |u| 
      u.send(:generate_remember_token)
      u.save
    end
  end

  def self.down
    change_table(:users) do |t|
      t.remove :confirmation_token,:remember_token
    end
  end
end
