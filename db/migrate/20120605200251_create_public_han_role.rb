class CreatePublicHanRole < ActiveRecord::Migration
  def up
    Role.find_or_create_by_name_and_application(:name=>'Public',:application=>'han')
  end

  def down
    Role.where(:name=>'Public',:application=>'han').delete_all
  end
end
