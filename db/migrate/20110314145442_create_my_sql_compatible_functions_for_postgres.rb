class CreateMySqlCompatibleFunctionsForPostgres < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.configurations[RAILS_ENV]["adapter"] == "postgresql"
      execute "CREATE OR REPLACE FUNCTION UTC_TIMESTAMP() RETURNS timestamp AS $$ SELECT current_timestamp at time zone 'utc'; $$ LANGUAGE SQL;"
      execute "CREATE OR REPLACE FUNCTION UNIX_TIMESTAMP(newtime timestamp without time zone) RETURNS BIGINT AS $$ SELECT EXTRACT(EPOCH FROM $1)::bigint AS result; $$ LANGUAGE SQL;"
      execute "CREATE LANGUAGE plpgsql;"
      execute "drop function IF EXISTS rebuilt_sequences() RESTRICT; \
        CREATE OR REPLACE FUNCTION  rebuilt_sequences() RETURNS integer as \
        $body$ \
          DECLARE sequencedefs RECORD; c integer ; \
          BEGIN \
            FOR sequencedefs IN Select \
              constraint_column_usage.table_name as tablename, \
              constraint_column_usage.table_name as tablename, \
              constraint_column_usage.column_name as columnname, \
              replace(replace(columns.column_default,'''::regclass)',''),'nextval(''','') as sequencename \
              from information_schema.constraint_column_usage, information_schema.columns \
              where constraint_column_usage.table_schema ='public' AND \
              columns.table_schema = 'public' AND columns.table_name=constraint_column_usage.table_name \
              AND constraint_column_usage.column_name = columns.column_name \
              AND columns.column_default is not null \
           LOOP \
              EXECUTE 'select max('||sequencedefs.columnname||') from ' || sequencedefs.tablename INTO c; \
              IF c is null THEN c = 0; END IF; \
              IF c is not null THEN c = c+ 1; END IF; \
              EXECUTE 'alter sequence ' || sequencedefs.sequencename ||' restart  with ' || c; \
           END LOOP; \
           RETURN 1; END; \
        $body$ LANGUAGE plpgsql;"
    end
  end

  def self.down
  end
end
