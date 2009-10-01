class RemoveIdFromOrganizationsUsers < ActiveRecord::Migration
  def self.up
    #remove_index :organizations_users, :id
    remove_column :organizations_users, :id
  end

  def self.down
    execute "ALTER TABLE `organizations_users`
                ADD COLUMN `id` INT(11) AUTO_INCREMENT NOT NULL FIRST,
                ADD PRIMARY KEY(`id`)"
  end
end
