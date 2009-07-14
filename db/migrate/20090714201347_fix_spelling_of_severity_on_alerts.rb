class FixSpellingOfSeverityOnAlerts < ActiveRecord::Migration
  def self.up
    rename_column :alerts, :severety, :severity
  end

  def self.down
    rename_column :alerts, :severity, :severety
  end
end
