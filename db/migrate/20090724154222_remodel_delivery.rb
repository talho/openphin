class RemodelDelivery < ActiveRecord::Migration
  def self.up
    change_table :deliveries do |t|
      t.remove :alert_id
      t.remove :user_id
      t.rename :acknowledged_at, :sys_acknowledged_at
      t.remove :organization_id
      t.integer :alert_attempt_id
    end
  end

  def self.down
    change_table :deliveries do |t|
      t.remove :alert_attempt_id
      t.integer :organization_id
      t.rename :sys_acknowledged_at, :acknowledged_at
      t.integer :user_id
      t.integer :alert_id
    end
  end
end
