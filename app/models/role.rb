# == Schema Information
#
# Table name: roles
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  description       :string(255)
#  phin_oid          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  approval_required :boolean
#  alerter           :boolean
#  user_role         :boolean         default(TRUE)
#

class Role < ActiveRecord::Base
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  
  ADMIN = "Admin"
  ORG_ADMIN = "OrgAdmin"
  
  def self.admin
    find_or_create_by_name ADMIN
  end
  
  def self.org_admin
    find_by_name ORG_ADMIN
  end
  
  named_scope :user_roles, :conditions => { :user_role => true }
  
  validates_uniqueness_of :name
end
