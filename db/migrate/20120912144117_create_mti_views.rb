class CreateMtiViews < ActiveRecord::Migration
  def up
    create_mti_views
  end

  def down
    drop_mti_views
  end
end
