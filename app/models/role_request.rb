# == Schema Information
#
# Table name: role_requests
#
#  id              :integer(4)      not null, primary key
#  requester_id    :integer(4)
#  role_id         :integer(4)
#  approver_id     :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer(4)
#  user_id         :integer(4)
#

class RoleRequest < ActiveRecord::Base
  validates_presence_of :role
  validates_presence_of :jurisdiction
  validates_presence_of :user, :if => lambda { |rr| !rr.new_record? }
  validate_on_create do |req|
    unless req.user.blank? || req.user.role_memberships.find_by_role_id_and_jurisdiction_id(req.role_id, req.jurisdiction_id).nil?
      req.errors.add("User is already a member of this role and jurisdiction")
    end
  end
  validates_uniqueness_of :role_id, :scope => [:jurisdiction_id, :user_id], :message => "has already been requested for this jurisdiction."
  
  attr_protected :approver_id

  belongs_to :user
  belongs_to :requester,  :class_name => "User", :foreign_key => "requester_id"
  belongs_to :approver,   :class_name => "User", :foreign_key => "approver_id"
  belongs_to :role,       :class_name => "Role", :foreign_key => "role_id"
  belongs_to :jurisdiction
  has_one :role_membership, :dependent => :delete

  named_scope :unapproved, :conditions => ["approver_id is null"]
  named_scope :in_jurisdictions, lambda { |jurisdictions|
    {:conditions => ["jurisdiction_id in (?)", jurisdictions]}
  }

  before_create :set_requester_if_nil
  after_create :auto_approve_if_public_role
  after_create :auto_approve_if_approver_is_specified
  after_create :auto_approve_if_requester_is_jurisdiction_admin

  def approved?
    true if approver
  end
  
  def approve!(approving_user)
    unless RoleMembership.already_exists?(user, role, jurisdiction)
      self.approver=approving_user
      create_role_membership(:user => user, :role => role, :jurisdiction => jurisdiction)
      self.save
      AppMailer.deliver_role_assigned(role, jurisdiction, user, approver) unless user == approver
    end 
  end
  
  def deny!
    self.destroy
  end
  
  private 

  def auto_approve_if_public_role
    approve!(user) unless role.approval_required?
  end
  
  def auto_approve_if_requester_is_jurisdiction_admin
    approve!(requester) if requester && requester.is_admin_for?(jurisdiction)
  end
  
  def auto_approve_if_approver_is_specified
    approve!(approver) if !approver.blank? && approver.is_admin_for?(jurisdiction)
  end

  def set_requester_if_nil
    requester = user if requester.blank?
  end
    
end
