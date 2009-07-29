class ConvertIdFieldsToIntegers < ActiveRecord::Migration
  def self.up
    change_table :role_requests do |t|
      t.change   "requester_id", :integer
      t.change   "role_id", :integer
      t.change   "approver_id", :integer
    end
  end

  def self.down
    change_table :role_requests do |t|
      t.change   "requester_id", :string
      t.change   "role_id", :string
      t.change   "approver_id", :string
    end
  end
end
