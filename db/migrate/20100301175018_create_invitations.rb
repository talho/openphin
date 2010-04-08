class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :name
      t.text :body
      t.integer :organization_id
      t.integer :author_id
      t.string :subject

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
