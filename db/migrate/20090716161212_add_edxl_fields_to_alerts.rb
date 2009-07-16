class AddEdxlFieldsToAlerts < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.integer :from_organization_id
      t.string :from_organization_name, :from_organization_oid
      t.string :identifier, :scope, :category, :program, :urgency,
        :certainty, :jurisdictional_level
    end
  end

  def self.down
    change_table :alerts do |t|
      t.remove :from_organization_id, :from_organization_name, :from_organization_oid,
        :identifier, :scope, :category, :program, :urgency,
        :certainty, :jurisdictional_level
    end
  end
end
