# == Schema Information
#
# Table name: audiences
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  owner_id              :integer(4)
#  scope                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  owner_jurisdiction_id :integer(4)
#  type                  :string(255)
#

class Audience < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  belongs_to :owner_jurisdiction, :class_name => "Jurisdiction"
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users

  validate :at_least_one_recipient?

  def self.by_jurisdictions(jurisdictions)
    jur_ids = jurisdictions.map(&:id).compact.uniq
    Group.find_all_by_owner_jurisdiction_id(jur_ids)
  end
  
  def foreign_jurisdictions
    Array(jurisdictions.foreign.root)
  end
  
  #TODO: opportunity for optimization:  perform this function in SQL, not using map
  def foreign_users
    @foreign_users ||= users.reject{|u| u.jurisdictions.foreign.empty? }
  end

  def recipients
    # if users.empty?
    #   if jurisdictions && jurisdictions.empty?
    #     if jurisdictional_level =~ /local/i
    #       jurisdictions << Jurisdiction.root.children.nonforeign.first.descendants
    #     end
    #     if jurisdictional_level =~ /state/i
    #       jurisdictions << Jurisdiction.root.children.nonforeign
    #     end
    #   end
    # end
    # roles = Role.all if roles.empty?
    
    user_ids_for_delivery = jurisdictions.map(&:user_ids).flatten
    user_ids_for_delivery &= roles.map(&:user_ids).flatten + Role.admin.users.map(&:id).flatten unless roles.empty?

    user_ids_for_delivery += user_ids

    User.find(user_ids_for_delivery)
  end

  private
  def at_least_one_recipient?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add_to_base("You must select at least one role, one jurisdiction, or one user.")
    end
  end
end
