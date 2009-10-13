class Group < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"

  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users

  validates_presence_of :owner
end
