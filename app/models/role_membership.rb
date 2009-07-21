# == Schema Information
#
# Table name: role_memberships
#
#  id              :integer         not null, primary key
#  role_id         :integer
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer
#  role_request_id :integer
#

class RoleMembership < ActiveRecord::Base
  belongs_to :role
  belongs_to :jurisdiction
  belongs_to :user
  belongs_to :role_request
  has_one :approver, :through => :role_request
  
  validates_presence_of :jurisdiction_id
  validates_presence_of :user_id
  validates_uniqueness_of :role_id, :scope => [ :jurisdiction_id, :user_id ]
  
  named_scope :alerter, :joins => :role, :conditions => {:roles => {:alerter => true}}
  named_scope :recent, :conditions => ["updated_at < ?",1.days.ago]
end
