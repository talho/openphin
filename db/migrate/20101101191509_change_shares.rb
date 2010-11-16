class ChangeShares < ActiveRecord::Migration
  def self.up
    convert_shares = []

   # say_with_time "Computing new values..." do
      #shares = Share.find(:all, :include => [:audiences])

     # shares.each do |share|
        # find the current audience. If it's singular, use it. If it's multiple, create a conjoined audience.
     #   audience = share.audiences.first

        # determine users that have unsubscribed from folders
     #   unsubscribed_users = share.targets.map(&:users).flatten - share.users

        # find the first owner
     #   owner = share.owners.first

        # find other users to give file permissions
     #   authors = share.owners[1..-1]

     #   convert_shares << {:share => share, :audience => audience, :unsubscribed_users => unsubscribed_users, :owner => owner, :authors => authors }
     # end
   # end

    change_table :shares do |t|
      t.integer :user_id
      t.index :user_id
    end

    create_table( :permissions ) do |t|
      t.integer :user_id, :null => false
      t.integer :share_id, :null => false
      t.integer :permission, :null => false
      t.index :user_id
      t.index :share_id
    end

    create_table(:opt_out_shares_users, :id => false) do |t|
      t.integer :user_id, :null => false
      t.integer :share_id, :null => false
      t.index :user_id
      t.index :share_id
    end

   # say_with_time "Re-inserting data" do

   #   Share.reset_column_information
   #   convert_shares.each do |share_data|
   #     share = Share.find(share_data[:share].id)
   #     share.update_attribute :user_id, share_data[:owner].id
   #     share.update_attribute :audience_id, share_data[:audience].id

   #     share_data[:authors].each do |user|
   #       Permissions.create(:user_id => user.id, :share_id => share.id, :permission => 1)
   #     end

   #     share_data[:unsubscribed_users].each do |user|
   #       OptOutSharesUser.create(:user_id => user.id, :share_id => share.id)
   #     end
   #   end

   # end

    change_table :shares do |t|
      t.change :user_id, :integer, :null => false
    end
    
  end

  def self.down

    change_table :shares do |t|
      t.remove_index :user_id
      t.remove :user_id
    end

    drop_table :permissions
    drop_table :opt_out_shares_users

  end
end
