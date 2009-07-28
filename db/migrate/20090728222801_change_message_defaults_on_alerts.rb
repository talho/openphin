class ChangeMessageDefaultsOnAlerts < ActiveRecord::Migration
  def self.up
    change_column_default :alerts, :message, ""
    change_column_default :alerts, :short_message, ""
  end

  def self.down
    change_column_default :alerts, :message, nil
    change_column_default :alerts, :short_message, nil
  end
end
