class AddRecipientViewAndFunctions < ActiveRecord::Migration
  def self.up
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
            
    execute "CREATE OR REPLACE FUNCTION sp_recipients(INT)
             RETURNS TABLE(id INT) AS $$    
                WITH RECURSIVE a(par_audience_id, audience_id) AS (
                 SELECT aud.id, aud.id
                 FROM audiences aud
                UNION
                 SELECT asa.audience_id, asa.sub_audience_id
                 FROM audiences_sub_audiences asa
                UNION
                 SELECT a.par_audience_id, asa.sub_audience_id
                 FROM a
                 JOIN audiences_sub_audiences asa on asa.audience_id = a.audience_id
                )
                SELECT DISTINCT vr.user_id
                FROM view_recipients vr
                JOIN a ON vr.audience_id = a.audience_id
                WHERE a.par_audience_id = $1
                ;
              $$ LANGUAGE sql;"
            
    execute "CREATE OR REPLACE FUNCTION sp_audiences_for_user(INT)
            RETURNS TABLE(id INT) AS $$
            WITH RECURSIVE a(user_id, audience_id) AS(
              SELECT vr.user_id, vr.audience_id
              FROM view_recipients vr
            UNION
              SELECT a.user_id, asa.audience_id
              FROM a
              JOIN audiences_sub_audiences asa ON a.audience_id = asa.sub_audience_id
            )
            SELECT DISTINCT a.audience_id
            FROM a
            WHERE a.user_id = $1; 
              $$ LANGUAGE sql;"

  end

  def self.down
    execute "DROP VIEW IF EXISTS view_recipients"
    execute "DROP FUNCTION IF EXISTS sp_recipients(int)"
    execute "DROP FUNCTION IF EXISTS sp_audience_parents(int)" # This function was in the migration shortly but was removed
    execute "DROP FUNCTION IF EXISTS sp_audiences_for_user(int)"
  end
end
