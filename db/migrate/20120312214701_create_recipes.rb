class CreateRecipes < ActiveRecord::Migration

  def self.up
    create_table :recipes, :force=> true do |t|
      t.string(:type)
    end
    create_table :recipe_internals, :force=> true do |t|
       t.string(:type)
    end
    drop_table :report_recipes
  end

  def self.down
    drop_table :recipes
    drop_table :recipe_internals
    create_table :report_recipes, :force => true, :id=>false do |t|
      # empty to just keep ActiveRecord from complicating
    end
  end

end


