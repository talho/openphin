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

  has_and_belongs_to_many :recipients_default, :join_table => 'audiences_recipients', :class_name => "User", :uniq => true do
    def with_no_hacc(options={})
      options[:conditions] = User.merge_conditions(options[:conditions], ["audiences_recipients.is_hacc = ?", false])
      scoped(options)
    end
  end

  def recipients(options={})
    refresh_recipients if options[:force] || self.recipients_expires.nil? || Time.now > self.recipients_expires
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

  def refresh_recipients
    self.update_attribute('recipients_expires', Time.now + 1.minute)
    ActiveRecord::Base.transaction do
      clear_recipients ? true : raise(ActiveRecord::Rollback)
      (update_users_recipients ? true : raise(ActiveRecord::Rollback)) unless self.users.empty?
      (update_jurisdictions_recipients ? true : raise(ActiveRecord::Rollback)) if self.roles.empty?
      (update_roles_recipients ? true : raise(ActiveRecord::Rollback)) if self.jurisdictions.empty?
      (update_roles_jurisdictions_recipients ? true : raise(ActiveRecord::Rollback)) unless self.roles.empty? && self.jurisdictions.empty?
      target = Target.find_by_audience_id(self.id)
      (update_han_coordinators_recipients ? true : raise(ActiveRecord::Rollback)) if target && target.item_type == "Alert"
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
    db = ActiveRecord::Base.connection()
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

  def update_han_coordinators_recipients
    alert = Target.find_by_audience_id(self.id).item
    jurs = alert.audiences.map(&:jurisdictions).flatten.uniq
    self.recipients.find_in_batches do |user|
      jurs |= user.map(&:jurisdictions).flatten
    end
    #jurs = jurs.flatten.compact.uniq
    # grab all jurisdictions we're sending to, plus the from jurisdiction and get their ancestors
    jurs = if alert.from_jurisdiction.nil?
      jurs.map(&:self_and_ancestors).flatten.uniq - (Jurisdiction.federal)
    else
      selves_and_ancestors = (jurisdictions + [alert.from_jurisdiction]).compact.map(&:self_and_ancestors)

      # union them all, but that may give us too many ancestors
      unioned = selves_and_ancestors[1..-1].inject(selves_and_ancestors.first){|union, list| list | union}

      # intersecting will give us all the ancestors in common
      intersected = selves_and_ancestors[1..-1].inject(selves_and_ancestors.first){|intersection, list| list & intersection}

      # So we grab the lowest common ancestor; ancestory at the loweest level
      ((unioned - intersected) + [intersected.max{|x, y| x.level <=> y.level}]).compact
    end

    db = ActiveRecord::Base.connection()
    sql = "INSERT INTO audiences_recipients (audience_id, user_id, is_hacc)"
    sql += " SELECT DISTINCT #{id}, rm.user_id, true FROM role_memberships AS rm LEFT OUTER JOIN audiences_recipients AS ar ON ar.user_id = rm.user_id AND ar.audience_id = #{id}"
    sql += " WHERE rm.role_id = #{Role.han_coordinator.id}"
    sql += " AND rm.jurisdiction_id IN (#{jurs.map(&:id).join(',')})"
    sql += " AND ar.user_id IS NULL"
    begin
      db.execute sql
    rescue
      return false
    end
    true
  end
end