class CreateJurisdictions < ActiveRecord::Migration
  def self.up
    create_table :jurisdictions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :jurisdictions
  end
end
