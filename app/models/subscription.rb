# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  channel_id :integer(4)
#  user_id    :integer(4)
#  owner      :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Subscription < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  
  named_scope :publishers, :conditions => {:owner => true}
end
