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
  belongs_to :audience, :include => [:roles, :jurisdictions, :users]
  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :users, :include => [:devices, :role_memberships]
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  after_create :update_item_type
  after_create :save_snapshot_of_users

  def save_snapshot_of_users &block
    user_ids = if block_given?
      yield
    end
    
    user_ids = audience.recipients.map(&:id) if user_ids.blank?
    user_ids << item.author_id if item.is_a?(Alert) # add the alert user, this is a hack because this most belongs in alert, but there's no good spot for it there. Alert is the only thing that uses Target, so it works out.
    self.user_ids = user_ids.uniq unless user_ids.empty?
  end

  def to_s
    item_type
  end

  #handle_asynchronously :save_snapshot_of_users                                                                                                                                                                                                                         

  private
  # polymorphic class does not set item_type correctly when inheritance is involved
  def update_item_type
    update_attribute('item_type', item.class.to_s)
  end

  def conditions_for(audience)
    jurs = audience.jurisdictions.map(&:id).join(",")
    if audience.roles.empty?
      if item.include_public_users?
        roles = Role.user_roles.map(&:id).join(",")
      else
        roles = Role.user_roles.approval_roles.map(&:id).join(",")
      end
    else
      roles = audience.roles.map(&:id).join(',')
    end

    users = audience.users.map(&:id).join(",")
    conditions = []
    conditions.push "role_memberships.jurisdiction_id in (#{jurs})" unless jurs.blank?
    conditions.push "role_memberships.role_id in (#{roles})" unless roles.blank?
    conditions = [conditions.join(" AND ")]
    conditions.push "users.id in (#{users})" unless users.blank?
    conditions.join(" OR ")
  end
end
