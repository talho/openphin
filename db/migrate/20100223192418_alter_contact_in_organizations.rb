class AlterContactInOrganizations < ActiveRecord::Migration
  def self.up
    
    Organization.all.each do |org|
      if User.find_by_email(org.contact_email).nil?
        raise MigrationException, e => "organization contact is missing. No changes to the database have been made."
      end
    end  
    add_column :organizations, :user_id, :integer

    Organization.reset_column_information
    Organization.all.each do |org|
      org.update_attribute(:user_id, User.find_by_email(org.contact_email).id)
    end
    remove_column :organizations, :contact_id
    remove_column :organizations, :contact_display_name
    remove_column :organizations, :contact_phone
    remove_column :organizations, :contact_email
    
  end

  def self.down
    
    add_column :organizations, :contact_id, :integer
    add_column :organizations, :contact_display_name, :string
    add_column :organizations, :contact_phone, :string
    add_column :organizations, :contact_email, :string

    Organization.reset_column_information
    Organization.all.each do |org|
      org.update_attribute(:contact_email, User.find(org.user_id).email )
      org.update_attribute(:contact_phone, "1111111111")
      org.update_attribute(:contact_display_name, User.find(org.user_id).display_name)
    end
    remove_column :organizations, :user_id
    puts "All organization contact phone numbers defaulted to 1111111111"

  end
  
end

