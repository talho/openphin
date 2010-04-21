class AlertAckLog < ActiveRecord::Base
  
  belongs_to :alert
  Types = %w(device jurisdiction total alert_response)
  
  validates_presence_of :alert_id
  validates_presence_of :item_type
  validates_inclusion_of :item_type, :in => Types
  validates_presence_of :acks
  validates_presence_of :total
  
  def acknowledged_percent
    total > 0 ? acks.to_f / total.to_f : 0.0
  end
end

