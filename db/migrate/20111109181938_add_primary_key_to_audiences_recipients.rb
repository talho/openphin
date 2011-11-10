class AddPrimaryKeyToAudiencesRecipients < ActiveRecord::Migration
  def self.up
    change_table :audiences_recipients do |t|
      t.timestamps
      t.column :id, :primary_key
    end
  end

  def self.down
    change_table :audiences_recipients do |t|
      t.remove_timestamps
      t.remove :id
    end
  end
end
