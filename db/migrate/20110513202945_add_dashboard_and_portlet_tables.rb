class AddDashboardAndPortletTables < ActiveRecord::Migration
  def self.up
    create_table :dashboards do |t|
      t.string :name
      t.integer :columns
    end

    create_table :portlets do |t|
      t.string :name
      t.string :xtype
      t.text :config
    end

    create_table :dashboards_portlets do |t|
      t.integer :dashboard_id
      t.integer :portlet_id
      t.boolean :draft
      t.integer :column
      t.index [:dashboard_id, :portlet_id]
    end

    create_table :audiences_dashboards do |t|
      t.integer :audience_id
      t.integer :dashboard_id
      t.integer :role
      t.index [:audience_id, :dashboard_id]
      t.index :role
    end
  end

  def self.down
    drop_table :dashboards_permissions
    drop_table :dashboards_porlets
    drop_table :porlets
    drop_table :dashboards
  end
end
