class AddLockVersionToTables < ActiveRecord::Migration
  def self.up
		add_column :alert_ack_logs, :lock_version, :integer, :default => 0, :null => false
		add_column :alert_attempts, :lock_version, :integer, :default => 0, :null => false
		add_column :alert_device_types, :lock_version, :integer, :default => 0, :null => false
		add_column :alerts, :lock_version, :integer, :default => 0, :null => false
		add_column :articles, :lock_version, :integer, :default => 0, :null => false
		add_column :audiences, :lock_version, :integer, :default => 0, :null => false
		add_column :audiences_jurisdictions, :lock_version, :integer, :default => 0, :null => false
		add_column :audiences_roles, :lock_version, :integer, :default => 0, :null => false
		add_column :audiences_users, :lock_version, :integer, :default => 0, :null => false
		add_column :channels, :lock_version, :integer, :default => 0, :null => false
		add_column :channels_documents, :lock_version, :integer, :default => 0, :null => false
		add_column :deliveries, :lock_version, :integer, :default => 0, :null => false
		add_column :devices, :lock_version, :integer, :default => 0, :null => false
		add_column :documents, :lock_version, :integer, :default => 0, :null => false
		add_column :folders, :lock_version, :integer, :default => 0, :null => false
		add_column :forums, :lock_version, :integer, :default => 0, :null => false
		add_column :invitations, :lock_version, :integer, :default => 0, :null => false
		add_column :invitees, :lock_version, :integer, :default => 0, :null => false
		add_column :jurisdictions, :lock_version, :integer, :default => 0, :null => false
		add_column :jurisdictions_organizations, :lock_version, :integer, :default => 0, :null => false
		add_column :organization_membership_requests, :lock_version, :integer, :default => 0, :null => false
		add_column :organization_requests, :lock_version, :integer, :default => 0, :null => false
		add_column :organizations, :lock_version, :integer, :default => 0, :null => false
		add_column :role_memberships, :lock_version, :integer, :default => 0, :null => false
		add_column :role_requests, :lock_version, :integer, :default => 0, :null => false
		add_column :roles, :lock_version, :integer, :default => 0, :null => false
		add_column :subscriptions, :lock_version, :integer, :default => 0, :null => false
		add_column :swn_notification_response, :lock_version, :integer, :default => 0, :null => false
		add_column :targets, :lock_version, :integer, :default => 0, :null => false
		add_column :targets_users, :lock_version, :integer, :default => 0, :null => false
		add_column :tfcc_campaign_activation_response, :lock_version, :integer, :default => 0, :null => false
		add_column :topics, :lock_version, :integer, :default => 0, :null => false
    add_column :users, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
		remove_column :alert_ack_logs, :lock_version
		remove_column :alert_attempts, :lock_version
		remove_column :alert_device_types, :lock_version
		remove_column :alerts, :lock_version
		remove_column :articles, :lock_version
		remove_column :audiences, :lock_version
		remove_column :audiences_jurisdictions, :lock_version
		remove_column :audiences_roles, :lock_version
		remove_column :audiences_users, :lock_version
		remove_column :channels, :lock_version
		remove_column :channels_documents, :lock_version
		remove_column :deliveries, :lock_version
		remove_column :devices, :lock_version
		remove_column :documents, :lock_version
		remove_column :folders, :lock_version
		remove_column :forums, :lock_version
		remove_column :invitations, :lock_version
		remove_column :invitees, :lock_version
		remove_column :jurisdictions, :lock_version
		remove_column :jurisdictions_organizations, :lock_version
		remove_column :organization_membership_requests, :lock_version
		remove_column :organization_requests, :lock_version
		remove_column :organizations, :lock_version
		remove_column :role_memberships, :lock_version
		remove_column :role_requests, :lock_version
		remove_column :roles, :lock_version
		remove_column :subscriptions, :lock_version
		remove_column :swn_notification_response, :lock_version
		remove_column :targets, :lock_version
		remove_column :targets_users, :lock_version
		remove_column :tfcc_campaign_activation_response, :lock_version
		remove_column :topics, :lock_version
    remove_column :users, :lock_version
  end
end
