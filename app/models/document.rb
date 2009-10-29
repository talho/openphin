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
  
  has_and_belongs_to_many :channels, :after_add => :share_with_channel
  has_many :targets, :as => :item, :after_add => :share
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
    
  belongs_to :user
  belongs_to :folder
  
  after_post_process :notify_channels_of_update
  
  named_scope :viewable_by, lambda{|user|
    {:conditions => ['documents.user_id = :user OR subscriptions.user_id = :user', {:user => user}],
    :include => {:channels => :subscriptions}}
  }

  named_scope :editable_by, lambda{|user|
    {:conditions => ['documents.user_id = :user OR (subscriptions.user_id = :user AND subscriptions.owner = :true)', {:user => user, :true => true}],
    :include => {:channels => :subscriptions}}
  }
  
  def viewable_by?(user)
    Document.viewable_by(user).exists?(id)
  end
  
  def editable_by?(user)
    Document.editable_by(user).exists?(id)
  end
  
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
  
  def share_with_channel(channel)
    DocumentMailer.deliver_document_addition(channel) unless channel.users.empty?
  end
  
  def notify_channels_of_update
    recipients = channels.map(&:users).flatten.uniq
    unless recipients.empty?
      DocumentMailer.deliver_document_update(self, recipients)
    end
  end
  
  def copy(user)
    user.documents.create! :file => self.file
  end
end
