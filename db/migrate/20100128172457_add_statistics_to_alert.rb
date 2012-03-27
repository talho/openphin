class AddStatisticsToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :options, :text
    #require 'app/models/alert'
    #add basic stats to all alerts
    # Alert.find_each(:batch_size=>100,:include=>[{:alert_attempts => {:user => :jurisdictions}}], :conditions => ["acknowledge = ?", true]) do |alert|
    #   aa_size = alert.alert_attempts.size.to_f
    #   stat_jurisdictions = alert.total_jurisdictions
    #   alert.statistics = Hash.new
    #   alert.statistics[:jurisdictions] = stat_jurisdictions.map{|j| {:name => j.name, :size => alert.attempted_users.with_jurisdiction(j).size.to_f, :acks => 0}}
    #   alert.statistics[:devices] = [{:device => "Device::ConsoleDevice", :size => aa_size, :acks => 0}]
    #   types = alert.alert_device_types.reject{|d| d.device == "Device::ConsoleDevice"}
    #   types.collect{|d| alert.statistics[:devices] << {:device => d.device,:size => aa_size, :acks => 0}}
    #   alert.statistics[:total_acks] = {:size => aa_size, :acks => 0}
    #   
    #   alert.alert_attempts.acknowledged.each do |attempt|
    #     alert.options[:statistics][:devices].each do |device|
    #       device[:acks] +=1 if device[:device] == attempt.acknowledged_alert_device_type.device
    #     end
    # 
    #     attempt.user.jurisdictions.each do |jur|
    #       if stat_jurisdictions.include?(jur)
    #         alert.options[:statistics][:jurisdictions].each do |stat_jur|
    #           stat_jur[:acks] +=1 if stat_jur[:name] == jur.name
    #         end
    #       end
    #     end
    # 
    #     alert.options[:statistics][:total_acks][:acks] += 1
    #   end
    #   alert.save!
    # end
  end

  def self.down
    remove_column :alerts, :options
  end
end
