# == Schema Information
#
# Table name: channels
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Channel < ActiveRecord::Base
  
  def to_s
    name
  end
end
