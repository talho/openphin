class AddMissingIndexes < ActiveRecord::Migration
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

    
    add_index :subscriptions, :user_id
    add_index :subscriptions, :channel_id
    add_index :alert_attempts, :organization_id
    add_index :alert_attempts, :acknowledged_alert_device_type_id
    add_index :alert_attempts, :user_id
    add_index :alert_attempts, :jurisdiction_id
    add_index :alert_attempts, :alert_id
    add_index :targets_users, [:user_id, :target_id]
    add_index :targets_users, [:target_id, :user_id]
    add_index :role_memberships, :role_id
    add_index :role_memberships, :role_request_id
    add_index :role_memberships, :jurisdiction_id
    add_index :schools, :district_id
    add_index :invitees, :invitation_id
    add_index :alerts, :from_organization_id
    add_index :alerts, :author_id
    add_index :alerts, :from_jurisdiction_id
    add_index :alerts, :original_alert_id
    add_index :documents, :owner_id
    add_index :targets, [:item_id, :item_type]
    add_index :targets, :creator_id
    add_index :targets, :audience_id
    add_index :topics, :poster_id
    add_index :topics, :forum_id
    add_index :school_district_daily_infos, :school_district_id
    add_index :organization_membership_requests, :organization_id
    add_index :organization_membership_requests, :approver_id
    add_index :organization_membership_requests, :user_id
    add_index :organization_membership_requests, :requester_id
    add_index :role_requests, :approver_id
    add_index :role_requests, :role_id
    add_index :role_requests, :jurisdiction_id
    add_index :role_requests, :requester_id
    add_index :audiences, :owner_id
    add_index :audiences, :owner_jurisdiction_id
    add_index :audiences, [:id, :type]
    add_index :rollcall_alerts, [:id, :type]
    add_index :rollcall_alerts, :absentee_report_id
    add_index :organization_requests, :approver_id
    add_index :organization_requests, :organization_id
    add_index :organization_requests, :jurisdiction_id
    add_index :deliveries, :device_id
    add_index :deliveries, :alert_attempt_id
    add_index :school_districts, :jurisdiction_id
    add_index :invitations, :author_id
    add_index :invitations, :organization_id
    add_index :folders, :user_id
    add_index :articles, :author_id
    add_index :alert_device_types, :alert_id
  end
  
  def self.down
    remove_index :subscriptions, :user_id
    remove_index :subscriptions, :channel_id
    remove_index :alert_attempts, :organization_id
    remove_index :alert_attempts, :acknowledged_alert_device_type_id
    remove_index :alert_attempts, :user_id
    remove_index :alert_attempts, :jurisdiction_id
    remove_index :alert_attempts, :alert_id
    remove_index :targets_users, :column => [:user_id, :target_id]
    remove_index :targets_users, :column => [:target_id, :user_id]
    remove_index :role_memberships, :role_id
    remove_index :role_memberships, :role_request_id
    remove_index :role_memberships, :jurisdiction_id
    remove_index :schools, :district_id
    remove_index :invitees, :invitation_id
    remove_index :alerts, :from_organization_id
    remove_index :alerts, :author_id
    remove_index :alerts, :from_jurisdiction_id
    remove_index :alerts, :original_alert_id
    remove_index :documents, :owner_id
    remove_index :targets, :column => [:item_id, :item_type]
    remove_index :targets, :creator_id
    remove_index :targets, :audience_id
    remove_index :topics, :poster_id
    remove_index :topics, :forum_id
    remove_index :school_district_daily_infos, :school_district_id
    remove_index :organization_membership_requests, :organization_id
    remove_index :organization_membership_requests, :approver_id
    remove_index :organization_membership_requests, :user_id
    remove_index :organization_membership_requests, :requester_id
    remove_index :role_requests, :approver_id
    remove_index :role_requests, :role_id
    remove_index :role_requests, :jurisdiction_id
    remove_index :role_requests, :requester_id
    remove_index :audiences, :owner_id
    remove_index :audiences, :owner_jurisdiction_id
    remove_index :audiences, :column => [:id, :type]
    remove_index :rollcall_alerts, :column => [:id, :type]
    remove_index :rollcall_alerts, :absentee_report_id
    remove_index :organization_requests, :approver_id
    remove_index :organization_requests, :organization_id
    remove_index :organization_requests, :jurisdiction_id
    remove_index :deliveries, :device_id
    remove_index :deliveries, :alert_attempt_id
    remove_index :school_districts, :jurisdiction_id
    remove_index :invitations, :author_id
    remove_index :invitations, :organization_id
    remove_index :folders, :user_id
    remove_index :articles, :author_id
    remove_index :alert_device_types, :alert_id
  end
end
