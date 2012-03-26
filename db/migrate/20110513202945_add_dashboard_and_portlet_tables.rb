class AddDashboardAndPortletTables < ActiveRecord::Migration
  def self.up
    create_table :dashboards do |t|
      t.string :name
      t.integer :columns
      t.integer :draft_columns
      t.timestamps
    end

    create_table :portlets do |t|
      t.string :name
      t.string :xtype
      t.text :config
      t.timestamps
    end

    create_table :dashboards_portlets do |t|
      t.integer :dashboard_id
      t.integer :portlet_id
      t.boolean :draft, :default => true, :null => true 
      t.integer :column
      t.timestamps
    end

    add_index :dashboards_portlets, [:dashboard_id, :portlet_id, :draft] 

    create_table :audiences_dashboards do |t|
      t.integer :audience_id
      t.integer :dashboard_id
      t.integer :role
      t.timestamps
    end

    add_index :audiences_dashboards, [:audience_id, :dashboard_id]
    add_index :audiences_dashboards, :role

    add_column :users, :dashboard_id, :integer
  end

  def self.down
    remove_column :users, :dashboard_id
    drop_table :audiences_dashboards
    drop_table :dashboards_portlets
    drop_table :portlets
    drop_table :dashboards
  end
end
