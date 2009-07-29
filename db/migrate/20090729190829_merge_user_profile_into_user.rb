class MergeUserProfileIntoUser < ActiveRecord::Migration
  
  class User < ActiveRecord::Base
    has_one :profile, :class_name => "MergeUserProfileIntoUser::UserProfile"
  end
  
  class UserProfile < ActiveRecord::Base
    belongs_to :user, :class_name => "MergeUserProfileIntoUser::User"
  end
  
  def self.up
    change_table :users do |t|
      t.text :credentials, :bio, :experience
      t.string :employer, :photo_file_name, :photo_content_type
      t.boolean :public
      t.integer :photo_file_size
      t.datetime :photo_updated_at
    end
    
    fields = [:credentials, :bio, :experience, :employer, :photo_file_name, :photo_content_type, :public, :photo_file_size, :photo_updated_at]
    
    User.all.each do |user|
      fields.each {|field| user.send("#{field}=", user.profile.send(field))} unless user.profile.nil?
      user.save!
    end
    
    drop_table :user_profiles
  end

  def self.down
    create_table "user_profiles", :force => true do |t|
      t.boolean  "public"
      t.text     "credentials"
      t.string   "employer"
      t.text     "experience"
      t.text     "bio"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "photo_file_name"
      t.string   "photo_content_type"
      t.integer  "photo_file_size"
      t.datetime "photo_updated_at"
    end
    
    User.all.each do |user|
      profile = user.build_profile
      fields.each {|field| user.profile.send("#{field}=", user.send(field))}
      profile.save!
    end
    
    change_table :users do |t|
      t.remove :credentials
      t.remove :bio
      t.remove :experience
      t.remove :employer
      t.remove :photo_file_name
      t.remove :photo_content_type
      t.remove :public
      t.remove :photo_file_size
      t.remove  :photo_updated_at
    end
  end
end
