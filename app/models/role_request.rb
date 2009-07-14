class RoleRequest < ActiveRecord::Base
  validates_presence_of :role_id
  validates_presence_of :requester_id
  belongs_to :requester, :class_name => "User", :foreign_key => "requester_id"
  belongs_to :approver,  :class_name => "User", :foreign_key => "approver_id"
  belongs_to :role, :class_name => "Role", :foreign_key => "role_id"
  belongs_to :jurisdiction

end
