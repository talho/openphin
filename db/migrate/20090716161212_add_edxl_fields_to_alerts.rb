class AddEdxlFieldsToAlerts < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.integer :from_organization_id
      t.string :from_organization_name, :from_organization_oid
      t.datetime :sent_at
      t.string :identifier, :type, :scope, :category, :program, :urgency,
        :certainty, :jurisdictional_level, :program_type
    end
  end

  def self.down
    change_table :alerts do |t|
      t.remove :from_organization_id, :from_organization_name, :from_organization_oid,
        :sent_at, :identifier, :type, :scope, :category, :program, :urgency,
        :certainty, :jurisdictional_level, :program_type
    end
  end
end
