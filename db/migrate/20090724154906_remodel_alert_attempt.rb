class RemodelAlertAttempt < ActiveRecord::Migration
  def self.up
    change_table :alert_attempts do |t|
      t.remove :device_id
      t.integer :organization_id
    end
  end

  def self.down
    change_Table :alert_attempts do |t|
      t.remove :organization_id
      t.integer :device_id
    end
  end
end
