# == Schema Information
#
# Table name: roles
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  description       :string(255)
#  phin_oid          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  public            :boolean(1)
#  alerter           :boolean(1)
#  user_role         :boolean(1)      default(TRUE)
#  app_id            :string(255)
#  public            :boolean(1)      default(FALSE)     

class Role < ActiveRecord::Base
  has_many :role_requests, :dependent => :delete_all
  has_many :role_memberships, :dependent => :delete_all
  has_many :users, :through => :role_memberships
  belongs_to :app
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :alerters, :conditions => {:alerter => true}
  scope :alphabetical, :order => 'name'
  
  Defaults = {
    :sysadmin => 'SysAdmin',
    :superadmin => 'SuperAdmin',
    :admin => 'Admin',
    :org_admin => 'OrgAdmin',
    :public => 'Public'
  }
  
  scope :recent, lambda{|limit| {:limit => limit, :order => "updated_at DESC"}}

  #stopgap solution for role permissions - to be killed when a comprehensive security model is implemented
  scope :for_app, lambda { |app| { :conditions => { "apps.#{app.is_a?(App) || (app.is_a?(Array) && app.first.is_a?(App)) ?  "id" : "name"}" => app}, :joins => :app } }
  
  scope :admins, ->(app = nil) { conditions = {:name => Defaults[:admin]}
                                       conditions["apps.name"] = app.to_s unless app.blank?
                                       {:conditions => conditions, :joins => :app} }
  scope :superadmins, ->(app = nil) { conditions = {:name => Defaults[:superadmin]}
                                            conditions["apps.name"] = app.to_s unless app.blank?
                                            {:conditions => conditions, :joins => :app} }
  
  def self.find_or_create_by_name_and_application(name, app, &block)
    r = Role.select("roles.*").joins(:app).where("apps.name" => app, "roles.name" => name).first
    unless r
      r = Role.new(name: name) do |role|
        yield role
      end
      r.app = App.where(name: app).first
      r.save!
    end
    r
  end
  
  def self.find_by_name_and_application(name, app)
    r = Role.select("roles.*").joins(:app).where("apps.name" => app, "roles.name" => name).first
  end
  
  def self.latest_in_secs
    recent(1).first.updated_at.utc.to_i
  end

  def self.admin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:admin],app) do |r|
        r.user_role = false
      end
  end
  
  def self.org_admin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:org_admin],app) do |r|
        r.user_role = false
      end
  end

  def self.superadmin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:superadmin],app) do |r|
        r.user_role = false
      end
  end

  def self.sysadmin
    find_or_create_by_name_and_application(Defaults[:sysadmin],"system") do |r|
      r.user_role = false
    end
  end

  def self.public(app = "phin")
    find_or_create_by_name_and_application(Defaults[:public],app) do |r|
      r.public = true
    end
  end

  def application
    app.name
  end

  scope :user_roles, :conditions => { user_role: true }
  scope :approval_roles, :conditions => { public: false }

  validates_uniqueness_of :name, :scope => :app_id

  def self.is_public?(role)
    role.public?
  end

  def display_name
    begin
      return "#{application.titleize}: #{name}"
    rescue
    end
    name
  end                            

  def to_s
    display_name
  end
      
end
