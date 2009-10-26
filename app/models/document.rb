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
#

class Document < ActiveRecord::Base
  has_attached_file :file, :path => ":rails_root/attachments/:attachment/:id/:filename"
  validates_attachment_presence :file
  
  has_and_belongs_to_many :channels
  has_many :targets, :as => :item, :after_add => :share
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
    
  belongs_to :user
  belongs_to :folder
  
  def to_s
    file_file_name
  end
  
  # used by Target to determine if public users should be included in recipients
  def include_public_users?
    false
  end
  
  def share(target)
    target.users.each do |user|
      user.documents.create! :file => self.file
    end
    DocumentMailer.deliver_document(self, target)
  end
end
