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

class Group < Audience
  has_many :group_snapshots
  has_many :alerts, :through => :group_snapshots
  
  SCOPES = ['Personal', 'Jurisdiction', 'Global']
  validates_inclusion_of :scope, :in => SCOPES
  
  validates_presence_of :owner
  validates_length_of :name, :allow_nil => false, :allow_blank => false, :within => 1..254 
  validates_presence_of :owner_jurisdiction, :if => Proc.new{|group| group.scope == "Jurisdiction"}

  named_scope :personal, lambda{{:conditions => ["scope = ?", "Personal"]}}
  named_scope :jurisdictional, lambda{{:conditions => ["scope = ?", "Jurisdiction"]}}
  named_scope :global, lambda{{:conditions => ["scope = ?", "Global"]}}
  
  # user_ids_for_delivery += groups.map(&:create_snapshot).map{|snap| snap.alert=self; snap.users}.flatten.map(&:id)
  
  def current_users
    unless @_current_users
      userlist=users
      if jurisdictions.any? && roles.any?
        userlist << jurisdictions.map{|j| j.users.with_roles(roles)}.flatten
      elsif jurisdictions.any? && roles.empty?
        userlist << jurisdictions.map(&:users).flatten
      elsif jurisdictions.empty? && roles.any?
        userlist << roles.map(&:users).flatten
      end
      @_current_users=userlist
    end
    @_current_users
  end
  
  def create_snapshot
    snap=group_snapshots.create
    snap.users = current_users
    snap.save
    snap
  end

  
  
end
