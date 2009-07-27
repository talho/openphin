# == Schema Information
#
# Table name: user_profiles
#
#  id                 :integer         not null, primary key
#  public             :boolean
#  credentials        :text
#  employer           :string(255)
#  experience         :text
#  bio                :text
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#

class UserProfile < ActiveRecord::Base
  belongs_to :user
	validates_presence_of :user
	
	has_attached_file :photo #, :styles => { :medium => "300x300>", :thumb => "100x100>" }
end
