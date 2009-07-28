# == Schema Information
#
# Table name: role_requests
#
#  id              :integer         not null, primary key
#  requester_id    :string(255)
#  role_id         :string(255)
#  approver_id     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer
#

class RoleRequest < ActiveRecord::Base
  validates_presence_of :role
  validates_presence_of :requester, :if => lambda { |rr| !rr.new_record? }
  
  attr_protected :approver_id
  
  belongs_to :requester, :class_name => "User", :foreign_key => "requester_id"
  belongs_to :approver,  :class_name => "User", :foreign_key => "approver_id"
  belongs_to :role, :class_name => "Role", :foreign_key => "role_id"
  belongs_to :jurisdiction
  has_one :role_membership

  named_scope :unapproved, :conditions => ["approver_id is null"]
  named_scope :in_jurisdictions, lambda { |jurisdictions|
    {:conditions => ["jurisdiction_id in (?)", jurisdictions]}
  }
  
  after_create :auto_approve_if_requester_is_jurisdiction_admin
  after_create :auto_approve_if_approver_is_specified
  
  def approved?
    true if approver
  end
  
  def approve!(approving_user)
    self.approver=approving_user
    create_role_membership(:user => requester, :role => role, :jurisdiction => jurisdiction)
    save!
  end
  
  def deny!
    self.destroy
  end
  
  private 
  
  def auto_approve_if_requester_is_jurisdiction_admin
    approve!(requester) if requester.is_admin_for?(jurisdiction)
  end
  
  def auto_approve_if_approver_is_specified
    approve!(approver) if !approver.blank?
  end
end
