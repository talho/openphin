
class FolderPermission < ActiveRecord::Base
  belongs_to :folder
  belongs_to :user
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  PERMISSION_TYPES = {:author => 1, :admin => 2}

  def to_s
    Folder.find(folder_id).to_s + ': ' + User.find(user_id).to_s
  end

end