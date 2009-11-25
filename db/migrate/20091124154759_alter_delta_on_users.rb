class AlterDeltaOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :delta, :boolean, :null => false, :default => true
    sql = ActiveRecord::Base.connection();
    sql.execute "UPDATE users SET delta=true"
  end

  def self.down
    change_column :users, :delta, :boolean, :null => true, :default => nil
  end
end