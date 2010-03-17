class AddHomePhoneMobliePhoneOrgPhoneAndOrgFaxToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :home_phone, :string
    add_column :users, :mobile_phone, :string
    add_column :users, :fax, :string
  end

  def self.down
    remove_column :users, :home_phone
    remove_column :users, :mobile_phone
    remove_column :users, :fax
  end
end
