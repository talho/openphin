# == Schema Information
#
# Table name: organization_types
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OrganizationType < ActiveRecord::Base
  has_many :organizations
end
