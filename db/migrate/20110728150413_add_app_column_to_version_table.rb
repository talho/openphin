class AddAppColumnToVersionTable < ActiveRecord::Migration
  def self.up
    change_table :versions do |t|
      t.string :app, :default => 'phin'
    end
    Version.update_all ['app = ?', 'phin']
  end

  def self.down
    remove_column :versions, :app
  end
end
