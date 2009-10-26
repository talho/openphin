class AddRegionToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :region, :string
  end

  def self.down
    remove_column :schools, :region
  end
end
