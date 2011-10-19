class DropReportRecipe < ActiveRecord::Migration
  def self.up
    drop_table "report_recipes"
    create_table "report_recipes", :force => true, :id=>false do |t|
      # empty to just keep ActiveRecord from complicating
    end
  end

  def self.down
    create_table "report_recipes", :force => true do |t|
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "audience_id"
      t.datetime "registered_at"
    end
  end
end
