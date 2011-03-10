class ConvertIdFieldsToIntegers < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.configurations[RAILS_ENV]["adapter"] == "postgresql"
      execute("CREATE OR REPLACE FUNCTION pc_chartoint(chartoconvert character varying) \
      RETURNS integer AS \
      $BODY$ \
      SELECT CASE WHEN trim($1) SIMILAR TO '[0-9]+' \
        THEN CAST(trim($1) AS integer) \
      ELSE NULL END; \

      $BODY$ \
        LANGUAGE 'sql' IMMUTABLE STRICT; \
      ALTER TABLE role_requests ALTER COLUMN requester_id TYPE integer USING pc_chartoint(requester_id); \
      ALTER TABLE role_requests ALTER COLUMN role_id TYPE integer USING pc_chartoint(role_id); \
      ALTER TABLE role_requests ALTER COLUMN approver_id TYPE integer USING pc_chartoint(approver_id); \
      DROP FUNCTION pc_chartoint(chartoconvert character varying);")
    else
      change_table :role_requests do |t|
        t.change   "requester_id", :integer
        t.change   "role_id", :integer
        t.change   "approver_id", :integer
      end
    end
  end

  def self.down
    change_table :role_requests do |t|
      t.change   "requester_id", :string
      t.change   "role_id", :string
      t.change   "approver_id", :string
    end
  end
end
