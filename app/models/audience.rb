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
    prepare_recipients(options)
  end

  def prepare_recipients(options = {})
    recipient_table = "temp_audience_#{self.id}"
    TempUser.set_table_name recipient_table
    db = ActiveRecord::Base.connection();

    begin
      db.execute "SELECT id FROM #{recipient_table} LIMIT 1"
    rescue
      options[:recreate] = true
    end

    if options[:recreate]
      begin
        db.execute "DROP TEMPORARY TABLE #{recipient_table}"
      rescue
      end

      has_roles = self.roles.size > 0
      has_jurisdictions = self.jurisdictions.size > 0
      has_users = self.users.size > 0

      publicsql = " AND `role_memberships`.role_id = `roles`.id AND `roles`.approval_required = true" unless options[:include_public]

      subselect = "SELECT GROUP_CONCAT(CONCAT_WS(' in ',`sub_roles`.name, `sub_jurisdictions`.name)) FROM role_memberships AS sub_role_memberships," +
        " roles AS sub_roles, jurisdictions AS sub_jurisdictions WHERE `sub_role_memberships`.user_id = `users`.id" +
        " AND `sub_role_memberships`.role_id = `sub_roles`.id AND `sub_role_memberships`.jurisdiction_id = `sub_jurisdictions`.id"

      subselect2 = "SELECT count(*) FROM role_memberships AS public_role_memberships, roles AS public_roles" +
        " WHERE `public_role_memberships`.user_id = `users`.id" +
        " AND `public_role_memberships`.role_id = `public_roles`.id AND `public_role_memberships`.jurisdiction_id = `audiences_jurisdictions`.jurisdiction_id" +
        " AND `public_roles`.approval_required = true"

      sql = "CREATE TEMPORARY TABLE #{recipient_table} "
      if has_roles || (has_roles && has_jurisdictions)
        sql += "(SELECT DISTINCT `users`.id, `users`.last_name, `users`.display_name, `users`.email"
        sql += ", (#{subselect}) AS memberships" if options[:role_memberships]
        sql += " FROM users, role_memberships, audiences_roles"
        sql += ", roles" if publicsql
        sql += ", audiences_jurisdictions" if has_jurisdictions
        sql += " WHERE `role_memberships`.user_id = `users`.id AND `users`.deleted_at IS NULL"
        sql += " AND `audiences_roles`.audience_id = #{self.id} AND `role_memberships`.role_id  = `audiences_roles`.role_id"
        sql += " AND `audiences_jurisdictions`.audience_id = #{self.id} AND `role_memberships`.jurisdiction_id = `audiences_jurisdictions`.jurisdiction_id" if has_jurisdictions
        sql += "#{publicsql})"
        sql += " UNION DISTINCT " if has_users
      else
        sql += "(SELECT DISTINCT `users`.id, `users`.last_name, `users`.display_name, `users`.email"
        sql += ", (#{subselect}) AS memberships" if options[:role_memberships]
        sql += " FROM users, role_memberships, audiences_jurisdictions"
        sql += " WHERE `role_memberships`.user_id = `users`.id AND `users`.deleted_at IS NULL"
        sql += " AND `audiences_jurisdictions`.audience_id = #{self.id} AND `role_memberships`.jurisdiction_id = `audiences_jurisdictions`.jurisdiction_id"
        sql += " AND (SELECT (#{subselect2}) > 0)" if publicsql
        sql += ")"
        sql += " UNION DISTINCT " if has_users
      end

      if has_users
        sql += "(SELECT DISTINCT `users`.id, `users`.last_name, `users`.display_name, `users`.email"
        sql += ", (#{subselect}) AS memberships" if options[:role_memberships]
        sql += " FROM users, audiences, audiences_users"
        sql += ", role_memberships, roles" if publicsql
        sql += " WHERE `audiences_users`.audience_id = #{id} AND `audiences_users`.user_id = `users`.id AND `users`.deleted_at IS NULL"
        sql += " AND `role_memberships`.user_id = `users`.id#{publicsql}" if publicsql
        sql += ")"
      end

      begin
        db.execute sql
      rescue
      end
      TempUser
    end
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

  protected
  def at_least_one_recipient?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add_to_base("You must select at least one role, one jurisdiction, or one user.")
    end
  end
end

class TempUser < ActiveRecord::Base
  set_primary_key "id"
end