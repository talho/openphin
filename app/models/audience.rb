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
  has_and_belongs_to_many :jurisdictions, :uniq => true
  has_and_belongs_to_many :roles, :uniq => true
  has_and_belongs_to_many :users, :uniq => true, :conditions => {:deleted_at => nil}
  
  belongs_to :forum
  named_scope :with_forum, :conditions => "forum_id is not NULL"
  named_scope :with_visible_forum, :include => :forum, :conditions => "forum_id  is not NULL and forums.hidden_at is NULL"

  named_scope :with_user, lambda {|user|
    { :conditions => [ "users.id = ?", user.id ], :joins => :users}
  }

  def self.by_jurisdictions(jurisdictions)
    jur_ids = jurisdictions.map(&:id).compact.uniq
    Group.find_all_by_owner_jurisdiction_id(jur_ids)
  end

  def foreign_jurisdictions
    first_foreign = jurisdictions.foreign.first
    if first_foreign
      [first_foreign.root]
    else
      []
    end
  end

  #TODO: opportunity for optimization:  perform this function in SQL, not using map
  def foreign_users
    @foreign_users ||= users.reject{|u| u.jurisdictions.foreign.empty? }
  end

  def recipients(options = {})
    unless @recips
      options = {:include_public => true}.merge(options)
      user_ids_for_delivery = jurisdictions.map do |jurisdiction|
        memberships = jurisdiction.role_memberships
        memberships = memberships.not_public_roles unless options[:include_public]
        memberships.map(&:user_id)
      end.flatten.uniq
      user_ids_for_delivery &= roles.map(&:user_ids).flatten + Role.admin.users.map(&:id).flatten unless roles.empty?

      user_ids_for_delivery += user_ids

      @recips = User.find(user_ids_for_delivery, :order => "last_name")
      @recips = options[:include_public] ? @recips : @recips.select(&:has_non_public_role?)
    end
    @recips
  end
  
  def copy
    attrs = self.attributes
    ["id","updated_at","creatd_at"].each{|item| attrs.delete(item)}
    a = Audience.new(attrs)
    jurisdictions.each{|jur| a.jurisdictions << jur}
    roles.each{|role| a.roles << role}
    users.each{|user| a.users << user}
    a
  end

  protected
  def at_least_one_recipient?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add_to_base("You must select at least one role, one jurisdiction, or one user.")
    end
  end
end
