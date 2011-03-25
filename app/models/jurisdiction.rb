# == Schema Information
#
# Table name: jurisdictions
#
#  id                     :integer(4)      not null, primary key
#  name                   :string(255)
#  phin_oid               :string(255)
#  description            :string(255)
#  fax                    :string(255)
#  locality               :string(255)
#  postal_code            :string(255)
#  state                  :string(255)
#  street                 :string(255)
#  phone                  :string(255)
#  county                 :string(255)
#  alerting_jurisdictions :string(255)
#  parent_id              :integer(4)
#  lft                    :integer(4)
#  rgt                    :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  fips_code              :string(255)
#  foreign                :boolean(1)      default(FALSE), not null
#

class Jurisdiction < ActiveRecord::Base
  acts_as_nested_set

  has_and_belongs_to_many :organizations
  has_many :role_memberships, :dependent => :delete_all
  has_many :users, :through => :role_memberships
  has_many :organization_memberships, :dependent => :delete_all
  has_many :organizations, :through => :organization_memberships
  has_many :role_requests, :dependent => :delete_all
  has_many :alert_attempts
  has_many :deliveries, :through => :alert_attempts

  has_paper_trail

  named_scope :admin, lambda{{:include => :role_memberships,
    :conditions => { :role_memberships => { :role_id => [Role.admin.id,Role.superadmin.id] } }}}
  named_scope :federal, lambda{{ :conditions => "parent_id IS NULL" }}
  named_scope :state, lambda {{:conditions => root ? "parent_id = #{root.id}" : "0=1"}}
  named_scope :nonroot, :conditions => "parent_id IS NOT NULL", :order => :name
  named_scope :parents, :conditions => "rgt - lft > 1", :order => :name
  named_scope :foreign, :conditions => { :foreign => true }
  named_scope :nonforeign, :conditions => { :foreign => false }, :order => :name
  named_scope :alphabetical, :order => 'name'

  named_scope :recent, lambda{|limit| {:limit => limit, :order => "updated_at DESC"}}
  
  validates_uniqueness_of :fips_code, :allow_nil => true, :allow_blank => true

  def self.latest_in_secs
    recent(1).first.updated_at.utc.to_i
  end

  def admins
    users.with_role(Role.admin)
  end

  def super_admins
    users.with_role(Role.superadmin)
  end

  def alerting_users
    Role.alerters.map{|role| users.with_role(role)}.uniq.flatten
  end

  def parent
    Jurisdiction.find(parent_id) unless !Jurisdiction.exists?(parent_id)
  end

  def self.non_foreign_state_before_descendants
    Jurisdiction.state.nonforeign | Jurisdiction.state.nonforeign.map{|jurisdiction| jurisdiction.descendants}.flatten.sort_by{|jurisdiction| jurisdiction.name}
  end

  def to_s
    name
  end
end
