# == Schema Information
#
# Table name: folders
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Folder < ActiveRecord::Base
  belongs_to :user
  
  def to_s
    name
  end
end
