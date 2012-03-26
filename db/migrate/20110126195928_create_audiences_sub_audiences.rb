class CreateAudiencesSubAudiences < ActiveRecord::Migration
  def self.up
    create_table :audiences_sub_audiences, :id => false do |t|
      t.integer :audience_id
      t.integer :sub_audience_id
    end
    
    add_index :audiences_sub_audiences, [:audience_id, :sub_audience_id], :uniq => true
  end

  def self.down
    drop_table :audiences_sub_audiences
  end
end
