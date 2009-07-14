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
#

class RoleMembership < ActiveRecord::Base
  belongs_to :role
  belongs_to :jurisdiction
  belongs_to :user
end
