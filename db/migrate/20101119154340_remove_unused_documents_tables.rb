class RemoveUnusedDocumentsTables < ActiveRecord::Migration
  def self.up

    change_table :folders do |t|
      t.integer :audience_id
      t.index :audience_id
      t.boolean :notify_of_audience_addition
      t.boolean :notify_of_document_addition
      t.boolean :notify_of_file_download
      t.boolean :expire_documents, :default => true
      t.boolean :notify_before_document_expiry, :default => true
    end

    Folder.reset_column_information

    create_table :folder_permissions do |t|
      t.integer :folder_id
      t.index :folder_id
      t.integer :user_id
      t.index :user_id
      t.integer :permission
    end

    add_column :documents, :delta, :boolean, :default => true
    Document.reset_column_information

    #find the shares that need to be converted
#    shares = execute('Select id, name from channels').all_hashes.map {|x| {:id => x['id'], :name => x['name']} }
#
#    shares.each do |share|
#      #find the subscribed people
#      users = execute("select user_id, owner from subscriptions where channel_id = #{share[:id]} order by created_at asc").all_hashes.map{ |x| {:id => x['user_id'], :owner => x['owner'] }}
#
#      #designate an owner
#      owner = users.select { |u| u[:owner].to_i == 1 }.first
#      owner = users.first if owner.nil?
#      next if owner.nil? # if we have no owner, then we need to skip this share.
#      users.delete(owner)
#
#      #create an audience for the shared folder
#      execute("insert into audiences (name, owner_id, created_at, updated_at) values ('#{share[:name]}', #{owner[:id].to_i}, NOW(), NOW())")
#      audience_id = execute("select id from audiences order by id desc limit 1").all_hashes.map{ |x| x['id'] }.first.to_i
#      users.each do |user|
#        execute("insert into audiences_users (audience_id, user_id) values (#{audience_id}, #{user[:id].to_i})")
#      end
#
#      #create a folder for the share
#      #check for unique folder name
#      name_matches = execute("select * from folders where user_id = #{owner[:id].to_i} and parent_id is null and (name = '#{share[:name]}' or name like '#{share[:name]} Share%')").num_rows
#      name = share[:name] + (name_matches > 0 ? " Share " + name_matches.to_s : "")
#      folder = Folder.create( :name => name, :user_id => owner[:id].to_i)
#      folder.audience_id = audience_id
#      folder.save!
#
#      folder.audience.recipients.length if folder.audience #cause the recipients to calculate, otherwise this won't pick up due to the way documents links to recipients.
#
#      #set share owners as admins for the folder
#      users.select { |u| u[:owner].to_i == 1 }.each do |user|
#        execute("insert into folder_permissions(folder_id, user_id, permission) values (#{folder.id}, #{user[:id].to_i}, 2)")
#      end
#
#      owner = User.find(owner[:id].to_i)
#      #copy documents for the share
#      document_ids = execute("select document_id from channels_documents where channel_id = #{share[:id].to_i}").all_hashes.map { |x| x['document_id'] }
#      document_ids.each do |doc|
#        document = Document.find(doc.to_i)
#        document.copy(owner, folder)
#      end
#    end

    drop_table :channels_documents
    drop_table :channels
    drop_table :subscriptions
  end

  def self.down
    remove_column :documents, :delta
    drop_table :folder_permissions
    remove_index :folders, :audience_id
    remove_column :folders, :audience_id
    remove_column :folders, :notify_of_audience_addition
    remove_column :folders, :notify_of_document_addition
    remove_column :folders, :notify_of_file_download
    remove_column :folders, :expire_documents
    remove_column :folders, :notify_before_document_expiry
  end
end
