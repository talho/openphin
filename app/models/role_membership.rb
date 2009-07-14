class RoleMembership < ActiveRecord::Base
  belongs_to :role
  belongs_to :jurisdiction
  belongs_to :user
end
