class AddAudienceToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :audience_id, :integer
    
    Organization.reset_column_information
    Organization.all.each do |org|
      audience = Audience.new
      User.find_by_sql("SELECT u.id AS user_id FROM users u, organizations_users ou WHERE ou.user_id = u.id AND ou.organization_id = #{org.id}").each do |row|
        audience.users << User.find(row["user_id"])
      end
      audience.save!
      org.audience = audience
      org.save!
    end
    drop_table :organizations_users
  end

  def self.down
    create_table "organizations_users", :id => false, :force => true do |t|
      t.integer  "user_id"
      t.integer  "organization_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    Organization.all.each do |org|
      Audience.find(org.audience_id).users.each do |user|
        if User.find_by_sql("SELECT count(*) AS count FROM organizations_users WHERE organization_id=#{org.id} AND user_id=#{user.id}").first["count"] == "0"
          execute "INSERT INTO organizations_users (user_id,organization_id,created_at) VALUES(#{user.id},#{org.id},NOW())"
        end
      end
    end
    remove_column :organizations, :audience_id
  end
end


