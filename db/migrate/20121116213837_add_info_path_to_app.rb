class AddInfoPathToApp < ActiveRecord::Migration
  def change
    change_table :apps do |t|
      t.string :info_path
    end
  end
end
