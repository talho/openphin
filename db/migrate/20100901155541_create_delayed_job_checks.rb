class CreateDelayedJobChecks < ActiveRecord::Migration
  def self.up
    create_table :delayed_job_checks do |t|
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :delayed_job_checks
  end
end
