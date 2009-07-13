class RoleMembership < ActiveRecord::Base
  belongs_to :phin_role
  belongs_to :phin_jurisdiction
  belongs_to :phin_person
end
