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
    :superadmin => 'SuperAdmin',\
    :admin => 'Admin',
    :org_admin => 'OrgAdmin',
    :public => 'Public'
  }
  
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "updated_at DESC"}}

  #stopgap solution for role permissions - to be killed when a comprehensive security model is implemented
  named_scope :for_app, lambda { |app| { :conditions => { :application => app } } }
  #named_scope :for_phin, :conditions => { :application => 'phin' }
  #named_scope :for_rollcall, :conditions => { :application => 'rollcall' }

  def self.latest_in_secs
    recent(1).first.updated_at.utc.to_i
  end

  def self.admin(app = nil)
    app.nil? ? find(:all, :conditions => {:user_role => false}) : find(:all, :conditions => {:user_role => false, :application => app})
  end

  def self.org_admin(app = nil)
    app.nil? ? find(:all, :conditions => {:name => Defaults[:org_admin]}) : find(:all, :conditions => {:name => Defaults[:org_admin], :application => app})
  end

  def self.superadmin(app = nil)
    app.nil? ? find(:all, :conditions => {:name => Defaults[:superadmin]}) : find(:all, :conditions => {:name => Defaults[:superadmin], :application => app})
  end

  def self.sysadmin
    find(:all, :conditions => {:name => Defaults[:sysadmin], :application => 'system'})
  end

  def self.public(app = nil)
    app.nil? ? find(:all, :conditions => {:user_role => true}) : find(:all, :conditions => {:user_role => true, :application => app})
  end

  named_scope :user_roles, :conditions => { :user_role => true }
  named_scope :approval_roles, :conditions => { :approval_required => true }

  validates_uniqueness_of :name

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
