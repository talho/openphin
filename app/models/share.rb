# == Schema Information
#
# Table name: shares
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
#  user_id :integer - owner
#  audience_id :integer - audience

class Share < ActiveRecord::Base

  before_validation_on_create :apply_audience

  has_and_belongs_to_many :documents
  #has_many :subscriptions
  #has_many :users, :through => :subscriptions do
  #  def owners
  #    scoped :conditions => {:subscriptions => {:owner => true}}
  #  end
  #end
  #has_many :targets, :as => :item, :after_add => :subscribe
  #has_many :audiences, :through => :targets
  #accepts_nested_attributes_for :audiences

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :audience
  has_many :permissions
  has_and_belongs_to_many :opt_out_users, :class_name => 'User', :join_table => 'opt_out_shares_users'
  has_many :authors, :through => :permissions, :source => 'user', :conditions => "permission = 1"

  def users
    User.scoped :joins => ', audiences_recipients, shares', :conditions => ['audiences_recipients.user_id = users.id and audiences_recipients.audience_id = shares.audience_id and shares.id = ?', self.id]
  end
  
  validates_length_of :name, :in => 1..32, :allow_blank => false, :message => "Share name cannot exceed 32 characters in length."
  validates_presence_of :audience, :owner

  #def owners
  #  users.owners
  #end
  
  def to_s
    name
  end
  
  def include_public_users?
    false
  end
  
  #def subscribe(target)
  #  target.users.each do |user|
  #    subscriptions.find_or_create_by_user_id user.id
  #  end
  #  DocumentMailer.deliver_share_invitation(self, target)
  #end
  #
  #def promote_to_owner(audience)
  #  audience.recipients(:include_public => false, :recreate => true).find_in_batches do |users|
  #    users.each do |user|
  #      subscriptions.find_by_user_id(user.id).update_attribute :owner, true
  #    end
  #  end
  #end

  def self.find_for(id, user)
    share = self.find(id, :include => [:permissions, :owner])
    if share.nil?
      nil
    elsif share.kind_of?(Array)
      share.select {|s| s.accessible_to?(user)}
    else
      share.accessible_to?(user) ? share : nil
    end
  end

  def accessible_to?(user)
    return owner == user || !audience.recipients(:conditions => ["users.id = ? and role_memberships.role_id <> ?", user.id, Role.public.id]).empty?
  end

  def apply_audience
    self.audience = Audience.new
  end
end
