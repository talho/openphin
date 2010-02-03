
class AddStatisticsToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :options, :text
    require 'app/models/alert'
    #add basic stats to all alerts
    Alert.all.each do |alert|
      alert.statistics = {
          :jurisdictions => alert.audiences.map{|aud|
            aud.jurisdictions.map{ |j|
              {:name => j.name,
               :size => alert.attempted_users.with_jurisdiction(j).size.to_f,
               :acks => alert.acknowledged_users.with_jurisdiction(j).size.to_f
              }
            }
          }.flatten,
          :devices => {}
      }
      alert.save
    end
  end

  def self.down
    remove_column :alerts, :options
  end
end
