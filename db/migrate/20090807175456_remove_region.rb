class RemoveRegion < ActiveRecord::Migration
  def self.up
    drop_table :regions
    remove_column :jurisdictions, :region_id
  end

  def self.down
    add_column :jurisdictions, :region_id, :integer
    create_table :regions do |t|
      t.string :name

      t.timestamps
    end
  end
end
