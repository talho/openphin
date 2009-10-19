class Document < ActiveRecord::Base
  has_attached_file :file
  validates_attachment_presence :file
  
  def to_s
    file_file_name
  end
end
