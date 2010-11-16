# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  share_id :integer(4)
#  user_id    :integer(4)
#  owner      :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Subscription < ActiveRecord::Base
  belongs_to :share
  belongs_to :user
  
  named_scope :publishers, :conditions => {:owner => true}

  validates_uniqueness_of :user_id, :scope => [:share_id]
end
