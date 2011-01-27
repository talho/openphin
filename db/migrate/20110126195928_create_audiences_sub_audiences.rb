class CreateAudiencesSubAudiences < ActiveRecord::Migration
  def self.up
    create_table :audiences_sub_audiences, :id => false do |t|
      t.integer :audience_id
      t.index [:audience_id, :sub_audience_id], :uniq => true
      t.integer :sub_audience_id
    end
  end

  def self.down
    drop_table :audiences_sub_audiences
  end
end
