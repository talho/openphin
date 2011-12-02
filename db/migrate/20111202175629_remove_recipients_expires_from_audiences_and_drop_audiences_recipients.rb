class RemoveRecipientsExpiresFromAudiencesAndDropAudiencesRecipients < ActiveRecord::Migration
  def self.up
    remove_index :audiences_recipients, :is_hacc
    remove_index :audiences_recipients, :user_id
    remove_index :audiences_recipients, :audience_id
    drop_table :audiences_recipients
    remove_column :audiences, :recipients_expires
  end

  def self.down
    add_column :audiences, :recipients_expires, :datetime, :default => nil, :null => true

    create_table :audiences_recipients, :id => false do |t|
      t.integer :audience_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :is_hacc, :default => false, :null => false
    end
    add_index :audiences_recipients, :audience_id
    add_index :audiences_recipients, :user_id
    add_index :audiences_recipients, :is_hacc
  end
end
