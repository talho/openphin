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
  has_and_belongs_to_many :documents
  has_many :subscriptions
  has_many :users, :through => :subscriptions do
    def owners
      scoped :conditions => {:subscriptions => {:owner => true}}
    end
  end
  has_many :targets, :as => :item, :after_add => :subscribe
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
  validates_length_of :name, :in => 1..32, :allow_blank => false, :message => "Share name cannot exceed 32 characters in length."

  def owners
    users.owners
  end

  def to_s
    name
  end
  
  def include_public_users?
    false
  end
  
  def subscribe(target)
    target.users.each do |user|
      subscriptions.find_or_create_by_user_id user.id
    end
    DocumentMailer.deliver_channel_invitation(self, target)
  end
  
  def promote_to_owner(audience)
    audience.recipients(:include_public => false, :recreate => true).find_in_batches do |users|
      users.each do |user|
        subscriptions.find_by_user_id(user.id).update_attribute :owner, true
      end
    end
  end
end
