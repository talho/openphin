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
  SCOPES = ['Personal', 'Jurisdiction', 'Global', 'Organization', 'Team']
  validates_inclusion_of :scope, :in => SCOPES
  validate :at_least_one_recipient?, :unless => Proc.new{|group| group.scope == "Organization"}

  validates_presence_of :owner, :unless => Proc.new{|group| group.scope == "Organization"}
  validates_length_of :name, :allow_nil => false, :allow_blank => false, :within => 1..254 
  validates_presence_of :owner_jurisdiction, :if => Proc.new{|group| group.scope == "Jurisdiction"}
  validates_uniqueness_of :name, :scope => [:scope], :if => Proc.new {|group| group.scope == "Global"}
  validates_uniqueness_of :name, :scope => [:scope, :owner_id], :if => Proc.new {|group| group.scope == "Personal"}
  validates_uniqueness_of :name, :scope => [:scope, :owner_jurisdiction_id], :if => Proc.new {|group| group.scope == "Jurisdiction"}
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :personal, lambda{{:conditions => ["scope = ?", "Personal"]}}
  scope :jurisdictional, lambda{{:conditions => ["scope = ?", "Jurisdiction"]}}
  scope :global, lambda{{:conditions => ["scope = ?", "Global"]}}

  def to_s
   scope + ': ' + name
  end

  def as_report(options={})
    only = [:name,:scope]
    json = as_json(:only => only)
    json["jurisdictions"] = jurisdictions.map(&:name)
    json["roles"] = roles.map(&:name)
    json["owner_jurisdiction"] = owner_jurisdiction.name || ''
    options[:inject].each {|key,value| json[key] = value} if options[:inject]
    json
  end

end
