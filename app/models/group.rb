# == Schema Information
#
# Table name: groups
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  owner_id   :integer(4)
#  scope      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Group < ActiveRecord::Base
  #attr_protected :owner_id
  belongs_to :owner, :class_name => "User"

  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users

  validates_presence_of :owner
end
