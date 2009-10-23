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
  has_many :subscriptions
  has_many :users, :through => :subscriptions
  has_many :targets, :as => :item, :after_add => :subscribe
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences

  def to_s
    name
  end
  
  def subscribe(target)
    recipients = target.audience.recipients(:include_public => false)
    recipients.each do |user|
      subscriptions.find_or_create_by_user_id user.id
    end
  end
  
  def promote_to_owner(audience)
    audience.recipients(:include_public => false).each do |user|
      subscriptions.find_by_user_id(user.id).update_attribute :owner, true
    end
  end
end
