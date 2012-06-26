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
  validate :on => :create do |req|
    unless req.user.blank?
      req.errors.add("User is already a member of this role and jurisdiction") unless req.user.role_memberships.find_by_role_id_and_jurisdiction_id(req.role_id, req.jurisdiction_id).nil?
      req.errors.add("You do not have permission to request that role") unless req.role.approval_required == false || Role.for_app("phin").include?(req.role) || req.requester.apps.include?(req.role.application) || req.requester.is_sysadmin?
    end
  end
  validates_uniqueness_of :role_id, :scope => [:jurisdiction_id, :user_id], :message => "has already been requested for this jurisdiction.",
    :unless => Proc.new { |rr| !RoleRequest.find_all_by_jurisdiction_id_and_user_id(rr.jurisdiction_id, rr.user_id).map(&:approver_id).include?(nil)}
  
  attr_protected :approver_id

  belongs_to :user
  belongs_to :requester,  :class_name => "User", :foreign_key => "requester_id"
  belongs_to :approver,   :class_name => "User", :foreign_key => "approver_id"
  belongs_to :role,       :class_name => "Role", :foreign_key => "role_id"
  belongs_to :jurisdiction
  has_one :role_membership, :dependent => :delete
  has_paper_trail  :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :unapproved, :conditions => ["approver_id is null"]
  scope :in_jurisdictions, lambda { |jurisdictions|
    {:conditions => ["jurisdiction_id in (?)", jurisdictions],
     :include => [:user, :role, :jurisdiction]}
  }
  scope :for_apps, lambda { |applications|
    {:include => [:user, :role], :conditions => ["roles.application in (?)", applications]}
  }
  before_create :set_requester_if_nil
  after_create :auto_approve_if_public_role
  after_create :auto_approve_if_approver_is_specified
  after_create :auto_approve_if_requester_is_jurisdiction_admin
  after_create :notify_of_role_request

  def approved?
    true if approver
  end
  
  def approve!(approving_user)
    unless RoleMembership.already_exists?(user, role, jurisdiction)
      self.approver=approving_user
      create_role_membership(:user => user, :role => role, :jurisdiction => jurisdiction)
      if self.save
        AppMailer.role_assigned(role, jurisdiction, user, approver).deliver unless user == approver
      end
    end 
  end

  def deny!
    self.destroy
  end

  def to_s
    begin user_name = User.find(user_id).to_s rescue user_name = '-?-' end
    begin role_name = Role.find(role_id).to_s rescue role_name = '-?-' end
    begin jur_name = Jurisdiction.find(jurisdiction_id).to_s rescue jur_name = '-?-' end
    user_name + ' for ' + role_name + ' in ' + jur_name
  end

  def as_hash
    {"role"=>role.name,"jurisdiction"=>jurisdiction.name}
  end

  def notify_admin_of_request
    application          = self.role.application
    current_jurisdiction = self.jurisdiction
    admins               = []
    begin 
      admins = current_jurisdiction.admins(application)
      admins = current_jurisdiction.super_admins(application) if admins.blank?
      current_jurisdiction = current_jurisdiction.parent if admins.blank?
    end while admins.blank? && !current_jurisdiction.nil?
    
    admins.each do |admin|
      SignupMailer.admin_notification_of_role_request(self, admin).deliver
    end
  end
  
  private
  
  def notify_of_role_request
    RoleRequestMailer.user_notification_of_role_request(self).deliver if !approved?
  end

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
