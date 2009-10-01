class AddAckDistributionReferenceAndDistributionIdAndReferenceAndSenderIdToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :ack_distribution_reference, :string
    add_column :alerts, :distribution_id, :string
    add_column :alerts, :reference, :string
    add_column :alerts, :sender_id, :string
  end

  def self.down
    remove_column :alerts, :ack_distribution_reference
    remove_column :alerts, :distribution_id
    remove_column :alerts, :reference
    remove_column :alerts, :sender_id
  end
end
