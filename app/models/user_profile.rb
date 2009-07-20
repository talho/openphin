# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer         not null, primary key
#  photo       :binary
#  public      :boolean
#  credentials :text
#  employer    :string(255)
#  experience  :text
#  bio         :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class UserProfile < ActiveRecord::Base
  belongs_to :user
	validates_presence_of :user
	
end
