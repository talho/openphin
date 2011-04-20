
class FolderPermission < ActiveRecord::Base
  belongs_to :folder
  belongs_to :user
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  PERMISSION_TYPES = {:author => 1, :admin => 2}

  def to_s
    begin owner = User.find(user_id).to_s rescue owner = '-?-' end
    begin name = Folder.find(folder_id).to_s rescue name = '-?-' end
    name + ': ' + owner
  end

end