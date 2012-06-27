class AddHomeJurisdictionIdToUsers < ActiveRecord::Migration
  def up
    add_column :users, :home_jurisdiction_id, :integer
    
    execute("UPDATE users
             SET home_jurisdiction_id = js.jurisdiction_id
             FROM role_memberships AS js
             WHERE users.id = js.user_id")
  end
  
  def down
    remove_column :users, :home_jurisdiction_id
  end
end
