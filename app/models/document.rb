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
  
  has_many :targets, :as => :item, :after_add => :share
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
  
  has_many :shares
  
  def to_s
    file_file_name
  end
  
  def share(target)
    recipients = target.audience.recipients(:include_public => false)
    recipients.each do |user|
      shares.create! :user => user
    end
    DocumentMailer.deliver_document(self, target, recipients)
  end
end
