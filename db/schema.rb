# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090713195525) do

  create_table "contacts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", :force => true do |t|
    t.integer "phin_person_id"
    t.string  "type"
    t.string  "description"
    t.string  "name"
    t.string  "coverage"
    t.boolean "emergency_use"
    t.boolean "home_use"
  end

  create_table "phin_jurisdictions", :force => true do |t|
    t.string   "name"
    t.string   "phin_oid"
    t.string   "description"
    t.string   "fax"
    t.string   "locality"
    t.string   "postal_code"
    t.string   "state"
    t.string   "street"
    t.string   "phone"
    t.string   "county"
    t.string   "alerting_jurisdictions"
    t.string   "primary_organization_type"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phin_jurisdictions_phin_people", :force => true do |t|
    t.integer "phin_person_id"
    t.integer "phin_jurisdiction_id"
  end

  create_table "phin_organizations_phin_people", :force => true do |t|
    t.integer "phin_person_id"
    t.integer "phin_organization_id"
  end

  create_table "phin_people", :force => true do |t|
    t.string   "last_name"
    t.string   "phin_oid"
    t.text     "description"
    t.string   "display_name"
    t.string   "first_name"
    t.string   "email"
    t.string   "preferred_language"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "token",              :limit => 128
    t.datetime "token_expires_at"
    t.boolean  "email_confirmed",                   :default => false, :null => false
  end

  add_index "phin_people", ["email"], :name => "index_phin_people_on_email"
  add_index "phin_people", ["id", "token"], :name => "index_phin_people_on_id_and_token"
  add_index "phin_people", ["token"], :name => "index_phin_people_on_token"

  create_table "phin_person_profiles", :force => true do |t|
    t.binary   "photo"
    t.boolean  "public"
    t.text     "credentials"
    t.string   "employer"
    t.text     "experience"
    t.text     "bio"
    t.integer  "phin_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phin_roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "phin_oid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approval_required"
  end

  create_table "role_memberships", :id => false, :force => true do |t|
    t.integer "phin_role_id"
    t.integer "phin_person_id"
    t.integer "phin_jurisdiction_id"
  end

  create_table "role_requests", :force => true do |t|
    t.string   "requester_id"
    t.string   "role_id"
    t.string   "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phin_jurisdiction_id"
  end

end
