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

  after_create :save_snapshot_of_users


  def save_snapshot_of_users
#    ActiveRecord::Base.connection.execute(
#        "insert into targets_users (target_id, user_id)
#          select #{self.id}, users.id from users
#            inner join role_memberships on users.id=role_memberships.user_id
#          where #{conditions_for(audience)}"
#    )
    user_ids = if item_type == 'Alert' && !item.not_cross_jurisdictional
      audience.recipients.with_refresh(:select => "id", :force => true).map(&:id)
    elsif ["Channel", "Document"].include?(item_type)
      audience.recipients.with_refresh_and_no_hacc(:select => "id", :force => true, :conditions => ["role_memberships.role_id <> ?", Role.public.id], :include => :role_memberships).map(&:id)
    else
      audience.recipients.with_refresh_and_no_hacc(:select => "id", :force => true).map(&:id)
    end
    self.user_ids = user_ids.uniq unless user_ids.empty?
  end

  #handle_asynchronously :save_snapshot_of_users

  private
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
