class AddSubForumsOwnerAndModeratorAudienceToForums < ActiveRecord::Migration
  def change
    add_column :forums, :parent_id, :integer
    add_column :forums, :owner_id, :integer
    add_column :forums, :moderator_audience_id, :integer
  end
end
