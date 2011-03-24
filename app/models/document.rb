# == Schema Information
#
# Table name: documents
#
#  id                :integer(4)      not null, primary key
#  owner_id          :integer(4)
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer(4)
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer(4)
#  folder_id         :integer(4)
#

class Document < ActiveRecord::Base

  has_attached_file :file, :path => ":rails_root/attachments/:attachment/:id/:filename"
  validates_attachment_presence :file
  validate_on_create :validate_mime
  validate_on_create :validate_extension
  validate_on_create :validate_virus

  has_one :audience, :through => :folder
    
  belongs_to :user
  belongs_to :folder
  belongs_to :owner, :class_name => 'User'

  named_scope :shared_with_user, lambda{|user|
    {:joins => ', folders, audiences_recipients',
     :conditions => ['audiences_recipients.audience_id = folders.audience_id and audiences_recipients.user_id = ? and folders.user_id != ? and documents.folder_id = folders.id', user.id, user.id],
     :include => [:owner]
    }
  }

  def authors
    folder.authors
  end

  def admins
    folder.admins
  end

  def viewable_by? (user)
    if owner_id == user.id || audience.recipients.include?(user)
      true
    else
      false
    end
  end

  def viewable_by(user)
    self if viewable_by?(user)
  end

  def editable_by? (user)
    if owner_id == user.id || authors.include?(user) || admins.include?(user)
      true
    else
      false
    end
  end

  def editable_by(user)
    self if editable_by?(user)
  end

  def self.editable_by(user)
    user.documents | user.authoring_folders.map(&:documents).flatten | user.admin_shares.map(&:documents).flatten
  end


  def validate_mime
    # uses unix utility 'file' will not work on windows
    file_content_type = %x(file --mime-type -b #{file.queued_for_write[:original].path}).chomp
    unless CONTENT_TYPES.include? file_content_type
      errors.add("file"," Filetype not permitted. (#{file_content_type}) ")
    end
  end

  def validate_extension
    file_extension_type = File.extname(file_file_name)
    if  EXTENSION_TYPES.include? file_extension_type
      errors.add("file"," File extension not permitted. (#{file_extension_type}) ")
    end
  end

  def validate_virus
    if defined? CLAM_AV then     # bypass virus check if the virus checker disabled / not loaded
      virus_status = CLAM_AV.scanfile(file.queued_for_write[:original].path)
      if virus_status != 0
        errors.add("file"," #{file_file_name}: Virus detected! (#{virus_status}) ")
      end
    end
  end

  #def viewable_by?(user)
  #  Document.viewable_by(user).exists?(id)
  #end
  #
  #def editable_by?(user)
  #  Document.editable_by(user).exists?(id)
  #end
  
  def to_s
    file_file_name
  end
  
  # used by Target to determine if public users should be included in recipients
  def include_public_users?
    false
  end
  
  def share(target)
    target.users.each do |user|
      self.copy(user)
    end
    DocumentMailer.deliver_document(self, target)
  end
  
  def share_with_share(share)
    DocumentMailer.deliver_document_addition(share, self) unless share.users.empty?
  end
  
  def notify_shares_of_update
    shares.each do |share|
      recipients = share.users
      unless recipients.empty?
        DocumentMailer.deliver_document_update(self, recipients, share)
      end
    end
  end
  
  def copy(user, folder = nil)
    doc = Document.new :file => self.file, :owner => user, :folder => folder
    doc.save!
  end

  def ftype
    file_content_type
  end

  def name
    file_file_name
  end

  def as_json(options = {})
    options[:methods] = [] if options[:methods].nil?
    options[:methods] |= [:ftype, :name]
    super( options )
  end

  define_index do
    indexes file_file_name, :as => :name, :sortable => true

    has owner_id
    has folder(:id), :as => :folder_id
    has folder.audience(:id), :as => :audience_id
    has folder.audience.recipients_default(:id), :as => :shared_with_ids

    set_property :delta => :delayed
  end

private
  
 
=begin
  # callback used for delayed asynchronous processing
  # save entry in database but holdoff upload processing
  before_data_post_process do |document|
    false if document.processing?  # do not process if just added
  end
  
  # callback used for delayed asynchronous processing
  # add the document to the delayed job queue
  after_create do |document|
    Delayed::Job.enqueue DocumentJob.new(document.id)
  end
  
  # used for delayed asynchronous processing
  def perform
    self.processing = false # unlock for processing
    data.reprocess! # do the processing
    save
  end
=end
  
  
end
