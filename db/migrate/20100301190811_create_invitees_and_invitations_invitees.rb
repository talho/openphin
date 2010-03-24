class CreateInviteesAndInvitationsInvitees < ActiveRecord::Migration
  def self.up
    create_table :invitees do |t|
      t.string  :name,  :null => false
      t.string  :email, :null => false
      t.boolean :ignore, :null => false, :default => false
      t.references :invitation, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :invitees
  end
end
