# == Schema Information
#
# Table name: targets
#
#  id          :integer(4)      not null, primary key
#  audience_id :integer(4)
#  item_id     :integer(4)
#  item_type   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  creator_id  :integer(4)
#

class Target < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :audience
  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :users
  
  after_create :save_snapshot_of_users
  
private
  
  def save_snapshot_of_users
    self.users = audience.recipients(:include_public => item.include_public_users?)
  end

end
