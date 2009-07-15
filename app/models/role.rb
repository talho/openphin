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
  validates_uniqueness_of :name
end
