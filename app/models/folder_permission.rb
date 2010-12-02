
class FolderPermission < ActiveRecord::Base
  belongs_to :folder
  belongs_to :user

  PERMISSION_TYPES = {:author => 1, :admin => 2}
end