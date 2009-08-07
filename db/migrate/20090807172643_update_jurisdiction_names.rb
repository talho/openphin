class UpdateJurisdictionNames < ActiveRecord::Migration
  def self.up
    Jurisdiction.all.each do |jurisdiction|
      jurisdiction.name = jurisdiction.name.gsub(/\s+County$/, '')
      jurisdiction.save!
    end
  end

  def self.down
  end
end
