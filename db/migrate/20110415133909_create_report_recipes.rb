class CreateReportRecipes < ActiveRecord::Migration
  def self.up
    create_table :report_recipes, :force => true do |t|
      t.string    :type
      t.timestamps
    end
  end

  def self.down
    drop_table :report_recipes
  end
end
