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
#

class Role < ActiveRecord::Base
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  
  ADMIN = "Admin"
  
  def self.admin
    find_by_name ADMIN
  end
  
  validates_uniqueness_of :name
end
