class CreateReports < ActiveRecord::Migration
  def change
    drop_table :recipes
    drop_table :recipe_internals
    drop_table :report_reports
    
    create_table :reports do |t|
      t.integer :user_id
      t.string :type

      t.timestamps
    end
    
    add_index :reports, :user_id
  end
end
