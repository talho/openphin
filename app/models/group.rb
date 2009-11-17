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
  SCOPES = ['Personal', 'Jurisdiction', 'Global']
  validates_inclusion_of :scope, :in => SCOPES
  
  validates_presence_of :owner
  validates_length_of :name, :allow_nil => false, :allow_blank => false, :within => 1..254 
  validates_presence_of :owner_jurisdiction, :if => Proc.new{|group| group.scope == "Jurisdiction"}
  validates_uniqueness_of :name, :scope => [:scope], :if => Proc.new {|group| group.scope == "Global"}
  validates_uniqueness_of :name, :scope => [:scope, :owner_id], :if => Proc.new {|group| group.scope == "Personal"}
  validates_uniqueness_of :name, :scope => [:scope, :owner_jurisdiction_id], :if => Proc.new {|group| group.scope == "Jurisdiction"}

  named_scope :personal, lambda{{:conditions => ["scope = ?", "Personal"]}}
  named_scope :jurisdictional, lambda{{:conditions => ["scope = ?", "Jurisdiction"]}}
  named_scope :global, lambda{{:conditions => ["scope = ?", "Global"]}}
end
