# == Schema Information
#
# Table name: folders
#
#  create_table "folders", :force => true do |t|
#   t.string   "name"
#   t.integer  "user_id"
#   t.integer  "parent_id"
#   t.integer  "lft"
#   t.integer  "rgt"
#   t.datetime "created_at"
#   t.datetime "updated_at"
#   t.integer  "lock_version",                  :default => 0,    :null => false
#   t.integer  "audience_id"
#   t.boolean  "notify_of_audience_addition"
#   t.boolean  "notify_of_document_addition"
#   t.boolean  "notify_of_file_download"
#   t.boolean  "expire_documents",              :default => true
#   t.boolean  "notify_before_document_expiry", :default => true
# end
#

class Folder < ActiveRecord::Base
  has_many :documents, :dependent => :destroy do
    def expired(options = {})
      options[:conditions] = Document.merge_conditions(options[:conditions], ["created_at <= ?", 30.days.ago])
      scoped(options)
    end
    def expiring_soon(options = {})
      options[:conditions] = Document.merge_conditions(options[:conditions], ["created_at <= ? and created_at > ?", 25.days.ago, 26.days.ago])
      scoped(options)
    end
  end

  validates_uniqueness_of :name, :scope => [:parent_id, :user_id]

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :audience, :class_name => 'Audience'
  has_many :folder_permissions
  has_many :authors, :through => :folder_permissions, :source => 'user', :conditions => "permission = 1"
  has_many :admins, :through => :folder_permissions, :source => 'user', :conditions => 'permission = 2'
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def users
    self.audience.recipients
    #User.scoped :joins => ', folders', :conditions => ['folders.audience_id IN (select * from sp_audiences_for_user(users.id)) and folders.id = ?', self.id]
  end

  acts_as_nested_set :scope => :user_id

  def to_s
    name
  end

  def share_status
    if(!self.parent.nil? && self.audience_id == self.parent.audience_id)
      'inherited'
    elsif(!self.audience_id.nil?)
      'shared'
    else
      'not_shared'
    end
  end

  def owner? (user)
    if self.owner == user
      true
    else
      !self.permissions.first(:conditions => {:user_id => user.id, :permission => FolderPermission::PERMISSION_TYPES[:admin]}).nil?
    end
  end

  def author? (user)
    if self.owner == user
      true
    else
      !self.permissions.first(:conditions => {:user_id => user.id, :permission => [FolderPermission::PERMISSION_TYPES[:admin], FolderPermission::PERMISSION_TYPES[:author]]}).nil?
    end
  end

  def self.new( attributes = {} )
    shared_attr = attributes[:shared]
    attributes.delete(:shared)
    audience_attr = attributes[:audience]
    attributes.delete(:audience)
    permissions = attributes[:permissions]
    attributes.delete(:permissions)

    folder = super( attributes )

    parent = attributes[:parent_id].blank? ? nil : Folder.find(attributes[:parent_id])
    if(shared_attr == 'not_shared')
      folder.audience = nil
    elsif(shared_attr == 'shared')
      folder.audience = Audience.new( audience_attr )
    else #- on the create, the audience is going to be automatically none, so we don't have to worry about it
      folder.audience = parent.nil? ? nil : parent.audience
    end

    folder.permissions = permissions unless permissions.blank?

    folder
  end

  def attributes= (attributes)
    shared_attr = attributes[:shared]
    attributes.delete(:shared)
    audience_attr = attributes[:audience]
    attributes.delete(:audience)
    permissions = attributes[:permissions]
    attributes.delete(:permissions)

    super( attributes )

    prior_audience_id = self.audience_id
    old_audience = nil

    unless(shared_attr.blank?)
      if(shared_attr == 'inherited')
        self.audience = self.parent ? self.parent.audience : nil;
      elsif(shared_attr == 'shared')
        self.audience = Audience.new if self.audience.nil? || (self.parent && self.audience_id == self.parent.audience_id)
        self.audience.attributes = audience_attr
      elsif(!self.audience.nil?)
        old_audience = self.audience
        self.audience = nil
      end
    end

    cascade_inherited_audience(prior_audience_id) if (!self.audience.nil? && audience_id.nil?) || audience_id != prior_audience_id  #fall in if audience is new (unsaved) or if audience_id is different from what it was before
    old_audience.destroy if !old_audience.nil? && old_audience.folders.length <= 1

    self.permissions = permissions unless permissions.blank?

    attributes
  end

  def self.get_formatted_folders(current_user)
    folders = []
    Folder.each_with_level(current_user.folders) { |folder, level| folder[:level] = level + 1; folders << folder }
    folders = folders.sort_by {|f| f.name.downcase}

    folders.each do |folder|
      folder[:safe_parent_id] = (folder[:parent_id].nil? ? 0 : 'folder' + folder[:parent_id].to_s )
      folder[:safe_id] = 'folder' + folder[:id].to_s
      folder[:leaf] = folder.leaf?
      folder[:ftype] = 'folder'
      folder[:is_owner] = true
    end

    folders << {:name => "My Documents", :id => nil, :safe_id => 0, :safe_parent_id => nil, :parent_id => nil, :leaf => folders.empty?, :ftype => 'folder', :is_owner => true, :level => 0 }
    
    folders
  end

  def self.get_formatted_shares(current_user)
    shares = current_user.shares
    shares = shares.sort_by {|s| s.name.downcase}


    shares |= shares.map do |share|
      leaf = share.leaf?
      leaf = shares.select { |s| s.parent_id == share.id}.empty? unless leaf
      share[:leaf] = leaf
      share[:ftype] = 'share'
      share[:safe_id] = 'share' + share[:id].to_s
      share[:safe_parent_id] = share.parent_id.nil? || shares.select { |s| s.id == share.parent_id}.empty? ? nil : 'share' + share.parent_id.to_s
      share[:is_owner] = share.owner?(current_user)
      share[:is_author] = share.author?(current_user)
      
      unless share.owner.nil?
        user = {:name => share.owner.display_name, :id => nil, :safe_id => share.owner.id.to_s + share.owner.display_name.gsub(/ /, ''), :safe_parent_id => nil, :parent_id => nil, :leaf => false, :ftype => 'share', :level => 0}
        share[:safe_parent_id] = user[:safe_id] if share[:safe_parent_id].nil?
        return user
      end
    end.compact

    shares
  end

  def permissions= (permission_attributes)
    permission_attributes = JSON.parse(permission_attributes) if(permission_attributes.class == String)
    possible_removed_permissions = permission_attributes.select { |x| x['permission'] == 0 }
    permission_attributes.reject! { |x| x['permission'] == 0 }

    permission_attributes.each do |pa|
      per = self.folder_permissions.find_by_user_id( pa['user_id'].to_i )
      unless per.nil?
        per.update_attributes({:permission => pa['permission']});
      else
        self.folder_permissions.build(pa)
      end
    end

    possible_removed_permissions.each do |rp|
      per = self.folder_permissions.find_by_user_id( rp['user_id'].to_i )
      per.destroy unless per.nil?
    end
  end

  def permissions
    perms = []
    if share_status == 'shared'
      perms = folder_permissions
    elsif share_status == 'inherited'
      #find the parent that we have inherited from
      folder = parent
      while(!folder.nil? && folder.share_status == 'inherited')
        folder = folder.parent
      end
      perms = folder.folder_permissions unless folder.nil?
    end

    perms
  end

  def as_json(options = {})
    options[:methods] = [] if options[:methods].nil?
    options[:methods] |= [:share_status]
    super(options)
  end

  protected
  def cascade_inherited_audience(old_audience_id)
    children.each do |child|
      if(child.audience_id == old_audience_id)
        child.audience = audience
        child.save!
        child.cascade_inherited_audience(old_audience_id)
      end
    end
  end
end
