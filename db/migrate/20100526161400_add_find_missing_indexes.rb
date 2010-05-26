class AddFindMissingIndexes < ActiveRecord::Migration
  def self.up
  
    # These indexes were found by searching for AR::Base finds on your application
    # It is strongly recommanded that you will consult a professional DBA about your infrastucture and implemntation before
    # changing your database in that matter.
    # There is a possibility that some of the indexes offered below is not required and can be removed and not added, if you require
    # further assistance with your rails application, database infrastructure or any other problem, visit:
    #
    # http://www.railsmentors.org
    # http://www.railstutor.org
    # http://guides.rubyonrails.org
  
    add_index :devices, :id
    add_index :organizations, :id
    add_index :organizations, :phin_oid
    add_index :organizations, :token
    add_index :role_memberships, :id
    add_index :alert_attempts, :id
    add_index :alert_attempts, [:alert_id, :token]
    add_index :alert_attempts, [:token, :alert_id]
    add_index :subscriptions, :id
    add_index :schools, :id
    add_index :alerts, :id
    add_index :invitees, :id
    add_index :topics, :id
    add_index :targets, :id
    add_index :documents, :id
    add_index :organization_membership_requests, :id
    add_index :school_district_daily_infos, :id
    add_index :audiences, :scope
    add_index :role_requests, :id
    add_index :deliveries, :id
    add_index :forums, :id
    add_index :organization_requests, :id
    add_index :absentee_reports, :id
    add_index :jurisdictions, :id
    add_index :invitations, :id
    add_index :school_districts, :id
    add_index :alert_ack_logs, :id
    add_index :articles, :id
    add_index :folders, :id
    add_index :channels, :id
    add_index :roles, :id
    add_index :roles, :name
    add_index :alert_device_types, :id
  end

  def self.down
    remove_index :devices, :id
    remove_index :organizations, :id
    remove_index :organizations, :phin_oid
    remove_index :organizations, :token
    remove_index :role_memberships, :id
    remove_index :alert_attempts, :id
    remove_index :alert_attempts, :column => [:alert_id, :token]
    remove_index :alert_attempts, :column => [:token, :alert_id]
    remove_index :subscriptions, :id
    remove_index :schools, :id
    remove_index :alerts, :id
    remove_index :invitees, :id
    remove_index :topics, :id
    remove_index :targets, :id
    remove_index :documents, :id
    remove_index :organization_membership_requests, :id
    remove_index :school_district_daily_infos, :id
    remove_index :audiences, :scope
    remove_index :role_requests, :id
    remove_index :deliveries, :id
    remove_index :forums, :id
    remove_index :organization_requests, :id
    remove_index :absentee_reports, :id
    remove_index :jurisdictions, :id
    remove_index :invitations, :id
    remove_index :school_districts, :id
    remove_index :alert_ack_logs, :id
    remove_index :articles, :id
    remove_index :folders, :id
    remove_index :channels, :id
    remove_index :roles, :id
    remove_index :roles, :name
    remove_index :alert_device_types, :id
  end
end
