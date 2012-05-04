# == Schema Information
#
# Table name: organization_membership_requests
#
#  id              :integer(4)      not null, primary key
#  organization_id :integer(4)      not null
#  user_id         :integer(4)      not null
#  approver_id     :integer(4)
#  requester_id    :integer(4)
#

class OrganizationMembershipRequest < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  belongs_to :approver, :class_name => "User", :foreign_key => "approver_id"
  belongs_to :requester, :class_name => "User", :foreign_key => "requester_id"
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  attr_protected :approver_id

  validates_uniqueness_of :user_id, :scope => [:organization_id]

  before_create :set_requester_if_nil
  after_create :auto_approve_if_super_admin

  scope :unapproved, :conditions => ["approver_id is null"]
  
  def approved?
    true if approver
  end

  def approve!(approving_user)
    if !approved? && can_approve?(approving_user)
      organization.group.users << user
      self.approver=approving_user
      self.save
    end
  end

  def deny!
    self.destroy
  end

  def has_invitation?
    Invitation.find_all_by_organization_id(organization.id).each do |invitation|
      return true unless invitation.invitees.find_by_email(user.email).nil?
    end
    return false
  end

  def to_s
    begin req_name = User.find(requester_id).to_s rescue req_name = '-?-' end
    begin org_name = Organization.find(organization_id).to_s rescue org_name = '-?-' end
    req_name + ' for ' + org_name
  end

  private
  def set_requester_if_nil
    requester = user if requester.blank?
  end

  def can_approve?(user)
    return user.is_super_admin? || (user.is_admin?  && self.organization.has_user?(user))
  end

  def auto_approve_if_super_admin
    unless requester.nil?
      approver = User.find(requester_id)
      if approver.is_super_admin?
        approve!(approver)
      end
    end
  end

end

