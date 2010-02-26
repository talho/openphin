# == Schema Information
#
# Table name: organization_membership_requests
#
#  id              :integer(4)      not null, primary key
#  organization_id :integer(4)      not null
#  user_id         :integer(4)      not null
#  approver_id     :integer(4)
#

class OrganizationMembershipRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  belongs_to :approver, :class_name => "User", :foreign_key => "approver_id"

  attr_protected :approver_id
  
  def approved?
    true if approver
  end

  def approve!(approving_user)
    unless approved? || !approving_user.is_super_admin?
      organization.group.users << user
      self.approver=approving_user
      self.save
      OrganizationMembershipRequestMailer.deliver_user_notification_of_organization_membership_approval(organization, user, approver) unless user == approver
    end
  end

  def deny!
    self.destroy
  end

end

