# == Schema Information
#
# Table name: role_memberships
#
#  id              :integer(4)      not null, primary key
#  role_id         :integer(4)
#  user_id         :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer(4)
#  role_request_id :integer(4)
#

class RoleMembership < ActiveRecord::Base

  belongs_to :role
  belongs_to :jurisdiction
  belongs_to :user 
  belongs_to :role_request, :dependent => :delete
  has_one :approver, :through => :role_request
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  validates_presence_of :jurisdiction_id
  validates_presence_of :user
  validates_uniqueness_of :role_id, :scope => [ :jurisdiction_id, :user_id ]
  named_scope :user_roles, :include => [:role, :jurisdiction, :user], :conditions => {:roles => {:user_role => true}}
  named_scope :admin_roles, lambda{{ :include => :role, :conditions => {:role_id => Role.admin.id} }}
  named_scope :public_roles, lambda{{ :include => :role, :conditions => {:role_id => (defined?($public_roles) ? $public_roles | [Role.public.id] : Role.public.id)} }}
  named_scope :not_public_roles, lambda{{ :include => :role, :conditions => ["role_id != ?", Role.public.id] }}

  named_scope :all_roles, :include => [:role, :jurisdiction]

  named_scope :alerter, :joins => :role, :conditions => {:roles => {:alerter => true}}, :include => :jurisdiction
  named_scope :recent, lambda{{ :conditions => ["role_memberships.created_at > ?",1.days.ago] }}

  named_scope :role_jurisdiction, :select => 'role_id, jurisdiction_id'
  def as_hash
    Hash["role",role.name,"jurisdiction",jurisdiction.name]
  end 

  def self.already_exists?(user, role, jurisdiction)
    return true if RoleMembership.find_by_user_id_and_role_id_and_jurisdiction_id(user.id, role.id, jurisdiction.id, :include => [:user, :role, :jurisdiction])
    false
  end

  def to_s
    begin user_name = User.find(user_id).to_s rescue user_name = '-?-' end
    begin role_name = Role.find(role_id).to_s rescue role_name = '-?-' end
    begin jur_name = Jurisdiction.find(jurisdiction_id).to_s rescue jur_name = '-?-' end
    user_name + ', ' + role_name + ' in ' + jur_name
  end

end
