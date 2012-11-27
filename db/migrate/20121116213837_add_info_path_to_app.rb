class AddInfoPathToApp < ActiveRecord::Migration
  def change
    add_column :apps, :info_path, :string
    add_column :apps, :title, :string
  end
end
