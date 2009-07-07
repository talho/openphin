class CreateRoleRequests < ActiveRecord::Migration
  def self.up
    create_table :role_requests do |t|
      t.string :requester_id
      t.string :role_id
      t.string :approver_id

      t.timestamps
    end
  end

  def self.down
    drop_table :role_requests
  end
end
