class AlterDeltaOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :delta, :boolean, :null => false, :default => true
    User.all.each do |user|
      user.delta = true
      user.save
    end
  end

  def self.down
    change_column :users, :delta, :boolean, :null => true, :default => nil
  end
end