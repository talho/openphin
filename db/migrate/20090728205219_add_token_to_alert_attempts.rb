class AddTokenToAlertAttempts < ActiveRecord::Migration
  def self.up
    add_column :alert_attempts, :token, :string
  end

  def self.down
    remove_column :alert_attempts, :token
  end
end
