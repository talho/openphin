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

ActiveRecord::Schema.define(:version => 20090714184350) do

  create_table "alerts", :force => true do |t|
    t.string   "title"
    t.text     "message"
    t.string   "severety"
    t.string   "status"
    t.boolean  "acknowledge"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alerts_jurisdictions", :id => false, :force => true do |t|
    t.integer "alert_id"
    t.integer "jurisdiction_id"
  end

  add_index "alerts_jurisdictions", ["alert_id", "jurisdiction_id"], :name => "index_alerts_jurisdictions_on_alert_id_and_jurisdiction_id"
  add_index "alerts_jurisdictions", ["alert_id"], :name => "index_alerts_jurisdictions_on_alert_id"
  add_index "alerts_jurisdictions", ["jurisdiction_id"], :name => "index_alerts_jurisdictions_on_jurisdiction_id"

  create_table "alerts_organizations", :id => false, :force => true do |t|
    t.integer "alert_id"
    t.integer "organization_id"
  end

  add_index "alerts_organizations", ["alert_id", "organization_id"], :name => "index_alerts_organizations_on_alert_id_and_organization_id"
  add_index "alerts_organizations", ["alert_id"], :name => "index_alerts_organizations_on_alert_id"
  add_index "alerts_organizations", ["organization_id"], :name => "index_alerts_organizations_on_organization_id"

  create_table "alerts_roles", :id => false, :force => true do |t|
    t.integer "alert_id"
    t.integer "role_id"
  end

  add_index "alerts_roles", ["alert_id", "role_id"], :name => "index_alerts_roles_on_alert_id_and_role_id"
  add_index "alerts_roles", ["alert_id"], :name => "index_alerts_roles_on_alert_id"
  add_index "alerts_roles", ["role_id"], :name => "index_alerts_roles_on_role_id"

  create_table "alerts_users", :id => false, :force => true do |t|
    t.integer "alert_id"
    t.integer "user_id"
  end

  add_index "alerts_users", ["alert_id", "user_id"], :name => "index_alerts_users_on_alert_id_and_user_id"
  add_index "alerts_users", ["alert_id"], :name => "index_alerts_users_on_alert_id"
  add_index "alerts_users", ["user_id"], :name => "index_alerts_users_on_user_id"

  create_table "devices", :force => true do |t|
    t.integer "user_id"
    t.string  "type"
    t.string  "description"
    t.string  "name"
    t.string  "coverage"
    t.boolean "emergency_use"
    t.boolean "home_use"
    t.text    "options"
  end

  create_table "jurisdictions", :force => true do |t|
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

  create_table "organizations_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_memberships", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jurisdiction_id"
  end

  create_table "role_requests", :force => true do |t|
    t.string   "requester_id"
    t.string   "role_id"
    t.string   "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jurisdiction_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "phin_oid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approval_required"
    t.boolean  "alerter"
  end

  add_index "roles", ["alerter"], :name => "index_roles_on_alerter"

  create_table "user_profiles", :force => true do |t|
    t.binary   "photo"
    t.boolean  "public"
    t.text     "credentials"
    t.string   "employer"
    t.text     "experience"
    t.text     "bio"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
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

  add_index "users", ["email"], :name => "index_phin_people_on_email"
  add_index "users", ["id", "token"], :name => "index_phin_people_on_id_and_token"
  add_index "users", ["token"], :name => "index_phin_people_on_token"

end
