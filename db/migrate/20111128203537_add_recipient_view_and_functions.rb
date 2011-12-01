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
            
    execute "CREATE OR REPLACE FUNCTION sp_recipients(var_audience_id INT)
            RETURNS TABLE(id INT) AS $$
            BEGIN
              RETURN QUERY SELECT user_id
                FROM view_recipients vr
                WHERE vr.audience_id = var_audience_id
                UNION
                SELECT sp_recipients(a.id)
                FROM audiences_sub_audiences asa
                JOIN audiences a ON asa.sub_audience_id = a.id
                WHERE asa.audience_id = var_audience_id
                ;
            END;
            $$ LANGUAGE plpgsql;"
            
    execute "CREATE OR REPLACE FUNCTION sp_audience_parents(var_audience_id INT)
            RETURNS TABLE(id INT) AS $$
            BEGIN
              RETURN QUERY
              SELECT asa.audience_id
              FROM audiences_sub_audiences asa
              WHERE asa.sub_audience_id = var_audience_id
              UNION
              SELECT sp_audience_parents(asa.audience_id)
              FROM audiences_sub_audiences asa
              WHERE asa.sub_audience_id = var_audience_id;
            END;
            $$ LANGUAGE plpgsql;"

    execute "CREATE OR REPLACE FUNCTION sp_audiences_for_user(var_user_id INT)
            RETURNS TABLE(id INT) AS $$
            BEGIN
              IF EXISTS(select * from pg_tables where tablename = 'tmp_audiences' and tableowner = user)
                THEN DROP TABLE IF EXISTS tmp_audiences;
              END IF;
            
              CREATE TEMPORARY TABLE tmp_audiences(id INT);
            
              INSERT INTO tmp_audiences
              SELECT audience_id
              FROM view_recipients vr
              WHERE vr.user_id = var_user_id;
            
              INSERT INTO tmp_audiences
              SELECT sp_audience_parents(a.id)
              FROM tmp_audiences a;
            
              RETURN QUERY 
              SELECT DISTINCT *
              FROM tmp_audiences;
            END;
            $$ LANGUAGE plpgsql;" 
  end

  def self.down
    execute "DROP VIEW IF EXISTS view_recipients"
    execute "DROP FUNCTION IF EXISTS sp_recipients(int)"
    execute "DROP FUNCTION IF EXISTS sp_audience_parents(int)"
    execute "DROP FUNCTION IF EXISTS sp_audiences_for_user(int)"
  end
end
