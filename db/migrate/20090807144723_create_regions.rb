class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name

      t.timestamps
    end
    
    add_column :jurisdictions, :region_id, :integer
  end

  def self.down
    drop_table :regions
    remove_column :jurisdictions, :region_id
  end
end
