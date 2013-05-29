class RedoAudienceViewToBe92Friendly < ActiveRecord::Migration
  def up
    execute "CREATE OR REPLACE VIEW view_recipients AS
      SELECT distinct a.id AS audience_id, u.id AS user_id
      FROM users u
      JOIN role_memberships rm ON u.id = rm.user_id
      JOIN (audiences_roles ar
      FULL OUTER JOIN audiences_jurisdictions aj ON ar.audience_id = aj.audience_id)
        ON ar.role_id IS NULL AND rm.jurisdiction_id = aj.jurisdiction_id
        OR aj.jurisdiction_id is NULL AND rm.role_id = ar.role_id
        OR rm.jurisdiction_id = aj.jurisdiction_id AND rm.role_id = ar.role_id
      JOIN audiences a ON aj.audience_id = a.id OR ar.audience_id = a.id
      WHERE u.deleted_at IS NULL
      UNION
      SELECT distinct a.id, u.id
      FROM audiences a
      JOIN audiences_users au ON a.id = au.audience_id
      JOIN users u ON au.user_id = u.id
      WHERE u.deleted_at IS NULL
      "
  end

  def down
    execute "CREATE OR REPLACE VIEW view_recipients AS
      SELECT distinct a.id AS audience_id, u.id AS user_id
      FROM audiences a
      LEFT JOIN audiences_jurisdictions aj ON a.id = aj.audience_id
      LEFT JOIN audiences_roles ar ON a.id = ar.audience_id
      JOIN role_memberships rm ON (aj.jurisdiction_id IS NULL AND ar.role_id = rm.role_id) OR
                (ar.role_id IS NULL AND aj.jurisdiction_id = rm.jurisdiction_id) OR
                (ar.role_id IS NOT NULL AND aj.jurisdiction_id IS NOT NULL
                  AND ar.role_id = rm.role_id AND aj.jurisdiction_id = rm.jurisdiction_id)
      JOIN users u ON u.id = rm.user_id
      WHERE u.deleted_at IS NULL
      UNION
      SELECT distinct a.id, u.id
      FROM audiences a
      JOIN audiences_users au ON a.id = au.audience_id
      JOIN users u ON au.user_id = u.id
      WHERE u.deleted_at IS NULL
      "
  end
end
