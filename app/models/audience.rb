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

  validate :doesnt_contain_self_as_group
  
  has_many :folders

  has_and_belongs_to_many :jurisdictions, :uniq => true
  has_and_belongs_to_many :roles, :uniq => true
  has_and_belongs_to_many :users, :uniq => true, :conditions => {:deleted_at => nil}
  has_and_belongs_to_many :groups, :foreign_key => 'audience_id', :association_foreign_key => 'sub_audience_id', :uniq => true, :join_table => 'audiences_sub_audiences', :class_name => 'Group'
  has_and_belongs_to_many :sub_audiences, :foreign_key => 'audience_id', :association_foreign_key => 'sub_audience_id', :uniq => true, :join_table => 'audiences_sub_audiences', :class_name => 'Audience'
  has_and_belongs_to_many :parent_audiences, :foreign_key => 'sub_audience_id', :association_foreign_key => 'audience_id', :uniq => true, :join_table => 'audiences_sub_audiences', :class_name => 'Group'

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }
  
  has_and_belongs_to_many :recipients, :class_name => "User", :finder_sql => proc {
    "select distinct u.*
    from users u
    join sp_recipients(#{self.id}) r on u.id = r.id"
  }

  has_one :forum

  scope :with_forum, :conditions => "forum_id is not NULL"
  scope :with_visible_forum, :include => :forum, :conditions => "forum_id  is not NULL and forums.hidden_at is NULL"

  scope :with_user, lambda {|user|
    { :conditions => [ "users.id = ?", user.id ], :joins => :users}
  }

  def self.by_jurisdictions(jurisdictions)
    jur_ids = jurisdictions.map(&:id).compact.uniq
    Group.find_all_by_owner_jurisdiction_id(jur_ids)
  end

  def foreign_jurisdictions
    jurisdictions.foreign
  end

  #TODO: opportunity for optimization:  perform this function in SQL, not using map
  def foreign_users
    @foreign_users ||= users.reject{|u| u.jurisdictions.foreign.empty? }
  end                                                                        

  def copy
    attrs = self.attributes
    ["id","updated_at","created_at"].each{|item| attrs.delete(item)}
    a = Audience.new(attrs)
    jurisdictions.each{|jur| a.jurisdictions << jur}
    roles.each{|role| a.roles << role}
    users.each{|user| a.users << user}
    a
  end

  def to_s
    name.nil? ? 'anonymous' : name
  end

  def has_user?(user)
    user_id = user.class == User ? user.id : user
    !Audience.find_by_sql(["SELECT id FROM sp_audiences_for_user(?) where id = ?", user, self.id]).empty?
  end
  
  protected
  def at_least_one_recipient?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add(:base, "You must select at least one role, one jurisdiction, or one user.")
    end
  end

  private

  def doesnt_contain_self_as_group
    def check_recursion(group)
      if group.id == self.id
        errors.add(:base, "Group cannot be a member of itself or subgroups")
      else
        group.groups.each { |g| check_recursion(g) }
      end
    end
    
    self.groups.each { |g| check_recursion(g) }
  end
end
