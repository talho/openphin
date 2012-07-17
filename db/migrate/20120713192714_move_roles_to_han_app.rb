class MoveRolesToHanApp < ActiveRecord::Migration
  
  class App < ActiveRecord::Base
    has_many :roles
  end
  
  class Role < ActiveRecord::Base
    belongs_to :app
  end
  
  def up
    # ensure the han app exists
    MoveRolesToHanApp::App.reset_column_information
    MoveRolesToHanApp::Role.reset_column_information
    
    app = MoveRolesToHanApp::App.find_or_create_by_name('han')
    
    # re-app 'phin' roles that aren't admin, superadmin, orgadmin, or public
    execute "
      UPDATE roles
      SET app_id = #{app.id}
      FROM apps
      WHERE roles.app_id = apps.id
        AND apps.name = 'phin'
        AND roles.name NOT IN ('Public', 'SuperAdmin', 'Admin', 'OrgAdmin')
    "
    
    # add han public roles to users with han roles
    han_public = MoveRolesToHanApp::Role.find_or_create_by_name_and_app_id('Public', app.id) do |r|
      r.public = true
    end
    
    execute "
      INSERT INTO role_memberships(user_id, role_id, jurisdiction_id, created_at, updated_at)
      SELECT rm.user_id, #{han_public.id}, rm.jurisdiction_id, current_timestamp, current_timestamp
      FROM role_memberships rm
      JOIN roles r on rm.role_id = r.id
      WHERE r.app_id = #{app.id}
      GROUP BY rm.user_id, rm.jurisdiction_id 
    "
    
    # add han admin/superadmin roles to users with phin admin/superadmin roles
    han_admin = MoveRolesToHanApp::Role.find_or_create_by_name_and_app_id('Admin', app.id) do |r|
      r.user_role = false
    end    
    han_superadmin = MoveRolesToHanApp::Role.find_or_create_by_name_and_app_id('SuperAdmin', app.id) do |r|
      r.user_role = false
    end
    
    execute "
      INSERT INTO role_memberships(user_id, role_id, jurisdiction_id, created_at, updated_at)
      SELECT rm.user_id, CASE r.name WHEN 'Admin' THEN #{han_admin.id} WHEN 'SuperAdmin' THEN #{han_superadmin.id} END, rm.jurisdiction_id, current_timestamp, current_timestamp
      FROM role_memberships rm
      JOIN roles r on rm.role_id = r.id
      JOIN apps a on r.app_id = a.id
      WHERE a.name = 'phin'
        AND r.name IN ('Admin', 'SuperAdmin')
      GROUP BY rm.user_id, rm.jurisdiction_id, r.name 
    "
    
  end

  def down
    # remove han Public, Admin and SuperAdmin role_memberships
    execute "
      DELETE FROM role_memberships
      USING roles r, apps a
      WHERE a.name = 'han'
        AND r.app_id = a.id
        AND r.name IN ('Public', 'Admin', 'SuperAdmin')
        AND role_memberships.role_id = r.id
    "
    
    # remove han Public, Admin and SuperAdmin roles
    execute "
      DELETE FROM roles
      USING apps a
      WHERE a.name = 'han'
        AND roles.app_id = a.id
        AND roles.name IN ('Public', 'Admin', 'SuperAdmin')
    "
    
    phin = MoveRolesToHanApp::App.find_by_name('phin')
    han = MoveRolesToHanApp::App.find_by_name('han')
    
    # re-app 'han' roles
    execute "
      UPDATE roles
      SET app_id = #{phin.id}
      WHERE app_id = #{han.id}
    "
  end
end
