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
  belongs_to :owner_jurisdiction, :class_name => "Jurisdiction"
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users


  SCOPES = ['Personal', 'Jurisdiction', 'Global']

  validates_presence_of :owner
  validates_inclusion_of :scope, :in => SCOPES
  validates_presence_of :owner_jurisdiction, :if => Proc.new{|group| group.scope == "Jurisdiction"}
end
