# == Schema Information
#
# Table name: shares
#
#  id          :integer(4)      not null, primary key
#  document_id :integer(4)
#  user_id     :integer(4)
#  folder_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
  belongs_to :folder
  
  accepts_nested_attributes_for :document
end
