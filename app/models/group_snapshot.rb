class GroupSnapshot < ActiveRecord::Base
	belongs_to :alert
	belongs_to :group
	has_and_belongs_to_many :users
end
