# == Schema Information
#
# Table name: group_snapshots
#
#  id          :integer(4)      not null, primary key
#  audience_id :integer(4)
#  alert_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class GroupSnapshot < ActiveRecord::Base
	belongs_to :alert
	belongs_to :group, :foreign_key => 'audience_id'
	has_and_belongs_to_many :users
end
