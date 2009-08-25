class AddJurisdictionIdToAlertAttempts < ActiveRecord::Migration
  def self.up
    add_column :alert_attempts, :jurisdiction_id, :integer
  end

  def self.down
    remove_column :alert_attempts, :jurisdiction_id
  end
end
