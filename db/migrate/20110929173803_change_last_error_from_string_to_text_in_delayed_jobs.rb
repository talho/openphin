class ChangeLastErrorFromStringToTextInDelayedJobs < ActiveRecord::Migration
  def self.up
    change_column :delayed_jobs, :last_error, :text
  end

  def self.down
  end
end
