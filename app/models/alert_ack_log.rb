class AlertAckLog < ActiveRecord::Base
  
  belongs_to :alert, :polymorphic => true

  after_create :update_alert_type
  
  Types = %w(device jurisdiction total alert_response)
  
  validates_presence_of :alert_id
  validates_presence_of :item_type
  validates_inclusion_of :item_type, :in => Types
  validates_presence_of :acks
  validates_presence_of :total
  
  def acknowledged_percent
    total > 0 ? acks.to_f / total.to_f : 0.0
  end

  private
  def update_alert_type
    update_attribute('alert_type', alert.class.to_s)
  end
end

