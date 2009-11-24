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
#

class Role < ActiveRecord::Base
  has_many :role_requests, :dependent => :delete_all
  has_many :role_memberships, :dependent => :delete_all
  has_many :users, :through => :role_memberships

  named_scope :alerters, :conditions => {:alerter => true}
  named_scope :alphabetical, :order => 'name'
  default_scope :order => "user_role, name ASC"
  Defaults = {
    :admin => 'Admin',
    :org_admin => 'OrgAdmin',
    :superadmin => "Superadmin",
    :public => 'Public',
    :han_coordinator => 'Health Alert and Communications Coordinator'
  }

  def self.admin
    find_or_create_by_name_and_approval_required_and_user_role Defaults[:admin],true,false
  end

  def self.org_admin
    find_or_create_by_name_and_approval_required_and_user_role Defaults[:org_admin],true,false
  end

  def self.superadmin
    find_or_create_by_name_and_approval_required_and_user_role Defaults[:superadmin],true,false
  end

  def self.public
    find_or_create_by_name Defaults[:public]
  end

  def self.han_coordinator
    find_or_create_by_name Defaults[:han_coordinator]
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
    return "System:#{name}" unless user_role?
    name
  end

  def to_s
    display_name
  end
end
