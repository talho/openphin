class CreateAlertAckLog < ActiveRecord::Migration
  def self.up
    require 'app/models/alert_ack_log'
    remove_column :alerts, :options
    create_table :alert_ack_logs do |t|
      t.integer :alert_id, :null => false
      t.string  :item_type, :null => false
      t.string  :item
      t.integer :acks, :defaults => 0, :null => false
      t.integer :total, :defaults => 0, :null => false
      t.timestamps
    end
    Alert.find_each(:batch_size=>100,:include=>[{:alert_attempts => {:user => :jurisdictions}}], :conditions => ["acknowledge = ?", true]) do |alert|
      aa_size = alert.alert_attempts.size.to_f
      total_jurisdictions = alert.total_jurisdictions

      # initialize
      aald = {}
      alert.alert_device_types.each do |device|
        aald[device.device] = AlertAckLog.create!(:alert_id => alert.id, :item_type => "device", :item => device.device, :acks => 0, :total => aa_size)
      end
      aalj = {}
      total_jurisdictions.each do |jur|
        aalj[jur.name] = AlertAckLog.create!(:alert_id => alert.id, :item_type => "jurisdiction", :item => jur.name, 
          :acks => 0, :total => alert.attempted_users.with_jurisdiction(jur).size)
      end
      AlertAckLog.create!(:alert_id => alert.id, :item_type => "total", :acks => alert.alert_attempts.acknowledged.size, :total => aa_size)

      alert.alert_attempts.acknowledged.each do |attempt|
        aald[attempt.acknowledged_alert_device_type.device].acks +=1

        (attempt.user.jurisdictions & total_jurisdictions).each do |jur|
            aalj[jur.name].acks += 1
        end
      end

      # save the whole thing
      aald.each {|key,value| value.save!}
      aalj.each {|key,value| value.save!}
    end
    
  add_index :alert_ack_logs, :alert_id
  add_index :alert_ack_logs, :index_type
  end
  
  

  def self.down
    require 'app/models/alert'
    remove_index :alert_ack_logs, :alert_id
    remove_index :alert_ack_logs, :index_type
    drop_table :alert_ack_logs
    add_column :alerts, :options, :text
    
    # pita migration
     Alert.find_each(:batch_size=>100,:include=>[{:alert_attempts => {:user => :jurisdictions}}]) do |alert|
      aa_size = alert.alert_attempts.size.to_f
      stat_jurisdictions = alert.total_jurisdictions
      alert.statistics = Hash.new
      alert.statistics[:jurisdictions] = stat_jurisdictions.map{|j| {:name => j.name, :size => alert.attempted_users.with_jurisdiction(j).size.to_f, :acks => 0}}
      alert.statistics[:devices] = [{:device => "Device::ConsoleDevice", :size => aa_size, :acks => 0}]
      types = alert.alert_device_types.reject{|d| d.device == "Device::ConsoleDevice"}
      types.collect{|d| alert.statistics[:devices] << {:device => d.device,:size => aa_size, :acks => 0}}
      alert.statistics[:total_acks] = {:size => aa_size, :acks => 0}

      alert.alert_attempts.acknowledged.each do |attempt|
        alert.options[:statistics][:devices].each do |device|
          device[:acks] +=1 if device[:device] == attempt.acknowledged_alert_device_type.device
        end

        attempt.user.jurisdictions.each do |jur|
          if stat_jurisdictions.include?(jur)
            alert.options[:statistics][:jurisdictions].each do |stat_jur|
              stat_jur[:acks] +=1 if stat_jur[:name] == jur.name
            end
          end
        end

        alert.options[:statistics][:total_acks][:acks] += 1
      end
      alert.save!
    end

  end
end


