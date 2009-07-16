class AddReferencesToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :references, :string
  end

  def self.down
    remove_column :alerts, :references
  end
end
