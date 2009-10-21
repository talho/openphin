# == Schema Information
#
# Table name: folders
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  user_id    :integer(4)
#  parent_id  :integer(4)
#  lft        :integer(4)
#  rgt        :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :shares
  has_many :documents, :through => :shares
  
  acts_as_nested_set :scope => :user_id
  
  def to_s
    name
  end
end
