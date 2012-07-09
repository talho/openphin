class CreateSuperAdminHanRole < ActiveRecord::Migration
  def up
    Role.find_or_create_by_name_and_application(:name=>'SuperAdmin',:application=>'han')
  end

  def down
    Role.where(:name=>'SuperAdmin',:application=>'han').delete_all
  end
end
