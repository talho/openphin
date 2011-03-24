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
  has_and_belongs_to_many :recipients_default, :join_table => 'audiences_recipients', :class_name => "User", :uniq => true

  def recipients(options={})
    refresh_recipients(options)
    options.delete(:force)
    recipients_default.scoped(options)
  end

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

  def copy
    attrs = self.attributes
    ["id","updated_at","created_at"].each{|item| attrs.delete(item)}
    a = Audience.new(attrs)
    jurisdictions.each{|jur| a.jurisdictions << jur}
    roles.each{|role| a.roles << role}
    users.each{|user| a.users << user}
    a
  end

  # A block can be used to pass custom functionality to refresh_recipients (See HAN plugin)
  def refresh_recipients(options = {}, &block)
    return true unless options[:force] || self.recipients_expires.nil? || Time.now > self.recipients_expires
    
    self.update_attribute('recipients_expires', Time.now + 1.minute)
    ActiveRecord::Base.transaction do
      clear_recipients ? true : raise(ActiveRecord::Rollback)
      (update_users_recipients ? true : raise(ActiveRecord::Rollback)) unless self.users.empty?
      (update_jurisdictions_recipients ? true : raise(ActiveRecord::Rollback)) if self.roles.empty?
      (update_roles_recipients ? true : raise(ActiveRecord::Rollback)) if self.jurisdictions.empty?
      (update_roles_jurisdictions_recipients ? true : raise(ActiveRecord::Rollback)) unless self.roles.empty? && self.jurisdictions.empty?
      (update_groups_recipients ? true : raise(ActiveRecord::Rollback)) unless self.groups.empty?
      yield if block_given?
    end
    return true
  end

  protected
  def at_least_one_recipient?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add_to_base("You must select at least one role, one jurisdiction, or one user.")
    end
  end

  private
  def clear_recipients
    db = ActiveRecord::Base.connection()
    sql = "DELETE FROM audiences_recipients WHERE audience_id = #{id}"

    begin
      db.execute sql
    rescue
      return false
    end
    true
  end

  def update_jurisdictions_recipients
    db = ActiveRecord::Base.connection()
    jurisdictions.each do |j|
      sql = "INSERT INTO audiences_recipients (audience_id, user_id)"
      sql += " SELECT DISTINCT #{id}, rm.user_id FROM role_memberships AS rm LEFT OUTER JOIN audiences_recipients AS ar ON ar.user_id = rm.user_id AND ar.audience_id = #{id}"
      sql += " WHERE rm.jurisdiction_id = #{j.id} AND ar.user_id IS NULL"

      begin
        db.execute sql
      rescue
        return false
      end
    end
    true
  end

  def update_roles_recipients
    db = ActiveRecord::Base.connection()
    roles.each do |r|
      sql = "INSERT INTO audiences_recipients (audience_id, user_id)"
      sql += " SELECT DISTINCT #{id}, rm.user_id FROM role_memberships AS rm LEFT OUTER JOIN audiences_recipients AS ar ON ar.user_id = rm.user_id AND ar.audience_id = #{id}"
      sql += " WHERE rm.role_id = #{r.id} AND ar.user_id IS NULL"

      begin
        db.execute sql
      rescue
        return false
      end
    end
    true
  end

  def update_roles_jurisdictions_recipients
    db = ActiveRecord::Base.connection()
    jurisdictions.each do |j|
      roles.each do |r|
        sql = "INSERT INTO audiences_recipients (audience_id, user_id)"
        sql += " SELECT DISTINCT #{id}, rm.user_id FROM role_memberships AS rm LEFT OUTER JOIN audiences_recipients AS ar ON ar.user_id = rm.user_id AND ar.audience_id = #{id}"
        sql += " WHERE rm.jurisdiction_id = #{j.id} AND rm.role_id = #{r.id} AND ar.user_id IS NULL"

        begin
          db.execute sql
        rescue
          return false
        end
      end
    end
    true
  end

  def update_users_recipients
    # force the author to receive the alert
    db = ActiveRecord::Base.connection()
    target = Target.find_by_audience_id(self.id)
    unless target.nil?
      alert = target.item
      unless alert.nil?
        author_id = alert.author_id
        if author_id
          sql = "INSERT INTO audiences_recipients (audience_id, user_id) VALUES (#{id}, #{author_id}) "
          begin
            db.execute sql
          rescue
            return false
          end
        end
      end
    end

    sql = "INSERT INTO audiences_recipients (audience_id, user_id)"
    sql += " SELECT DISTINCT #{id}, au.user_id FROM audiences_users AS au LEFT OUTER JOIN audiences_recipients AS ar ON ar.user_id = au.user_id AND ar.audience_id = #{id}"
    sql += " WHERE au.audience_id = #{id} AND ar.user_id IS NULL"

    begin
      db.execute sql
    rescue
      return false
    end
    true
  end

  def update_groups_recipients
    db = ActiveRecord::Base.connection()
    self.groups.map(&:refresh_recipients)
    sql = "INSERT INTO audiences_recipients (audience_id, user_id)"
    sql += " SELECT DISTINCT #{self.id}, audiences_recipients.user_id FROM audiences_sub_audiences JOIN audiences_recipients ON audiences_sub_audiences.sub_audience_id = audiences_recipients.audience_id"
    sql += " WHERE audiences_sub_audiences.audience_id = #{self.id}"
    
    begin
      db.execute sql
    rescue
      return false
    end
    true
  end

  def determine_primary_audience_jurisdictions  # returns an array of jurisdiction objects
    target = Target.find_by_audience_id(self.id)
    alert = target ? target.item : nil
    jj = jurisdictions.map(&:id)    # ids of every specified jurisdiction
    rr = roles.map(&:id)            # ids of every specified role
    au = if alert && (alert.class == Alert || alert.superclass == Alert) && alert.from_jurisdiction
      users.map{|user| user.role_memberships.find_by_jurisdiction_id(alert.from_jurisdiction.id).nil? ? user : nil}.compact.map(&:id) # Don't include users that are in the same jurisdiction that the alert was sent from
    else
      users.map(&:id)
    end
    uu = RoleMembership.find_all_by_user_id(au).map(&:jurisdiction).map(&:id)           # ids of every jurisdiction that every manually-specified user has a role in

    if ( jj.size > 0 && rr.size > 0 )
      juris_ids = (RoleMembership.find_all_by_role_id_and_jurisdiction_id(rr,jj).map(&:jurisdiction_id) + uu).uniq   # an array of every role <-> juris association that matches plus userjuris
    else
      juris_ids = (RoleMembership.find_all_by_jurisdiction_id(jj).map(&:jurisdiction_id) + RoleMembership.find_all_by_role_id(rr).map(&:jurisdiction_id) + uu).uniq
    end
    jurs = Jurisdiction.find_all_by_id(juris_ids)
    return jurs.flatten.uniq
  end

  private
  def doesnt_contain_self_as_group
    def check_recursion(group)
      if group.id == self.id
        errors.add_to_base("Group cannot be a member of itself or subgroups")
      else
        group.groups.each { |g| check_recursion(g) }
      end
    end
    
    self.groups.each { |g| check_recursion(g) }
  end
end
