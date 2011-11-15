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
#  approval_required :boolean(1)
#  alerter           :boolean(1)
#  user_role         :boolean(1)      default(TRUE)
#  application       :string(255)     

class Role < ActiveRecord::Base
  has_many :role_requests, :dependent => :delete_all
  has_many :role_memberships, :dependent => :delete_all
  has_many :users, :through => :role_memberships
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  named_scope :alerters, :conditions => {:alerter => true}
  named_scope :alphabetical, :order => 'name'
  named_scope :public, :conditions => {:approval_required => false}
  named_scope :non_public, :conditions => {:approval_required => true}
  default_scope :order => "user_role, name ASC"

  Defaults = {
    :sysadmin => 'SysAdmin',
    :superadmin => 'SuperAdmin',
    :admin => 'Admin',
    :org_admin => 'OrgAdmin',
    :public => 'Public'
  }
  
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "updated_at DESC"}}

  #stopgap solution for role permissions - to be killed when a comprehensive security model is implemented
  named_scope :for_app, lambda { |app| { :conditions => { :application => app } } }
  
  named_scope :admins, ->(app = nil) { conditions = {:name => Defaults[:admin]}
                                       conditions[:application] = app.to_s unless app.blank?
                                       {:conditions => conditions} }
  named_scope :superadmins, ->(app = nil) { conditions = {:name => Defaults[:superadmin]}
                                            conditions[:application] = app.to_s unless app.blank?
                                            {:conditions => conditions} }
  
  def self.latest_in_secs
    recent(1).first.updated_at.utc.to_i
  end

  def self.admin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:admin],app) do |r| 
        r.approval_required = true
        r.user_role = false
      end
  end
  
  def self.org_admin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:org_admin],app) do |r| 
        r.approval_required = true
        r.user_role = false
      end
  end

  def self.superadmin(app = "phin")
      find_or_create_by_name_and_application(Defaults[:superadmin],app) do |r| 
        r.approval_required = true
        r.user_role = false
      end
  end

  def self.sysadmin
    find_or_create_by_name_and_application(Defaults[:sysadmin],"system") do |r| 
      r.approval_required = true
      r.user_role = false
    end
  end

  def self.public(app = "phin")
    find_or_create_by_name_and_application(Defaults[:public],app) {|r| r.user_role = true }
  end

  named_scope :user_roles, :conditions => { :user_role => true }
  named_scope :approval_roles, :conditions => { :approval_required => true }

  validates_uniqueness_of :name, :scope => :application

  def is_public?
    if name == Defaults[:public]
      return true
    end
    false
  end

  def self.is_public?(role)
    if(role.name == Defaults[:public])
      return true
    end
    false
  end

  def display_name
    begin
      return "#{application.titleize}: #{name}" unless user_role?
    rescue
    end
    name
  end                            

  def to_s
    display_name
  end
      
end
