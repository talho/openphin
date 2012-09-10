class AlertAckLog < ActiveRecord::Base
  
  belongs_to :alert, :polymorphic => true

  after_create :update_alert_type
  
  Types = %w(device jurisdiction total alert_response)
  
  validates_presence_of :alert_id
  validates_presence_of :item_type
  validates_inclusion_of :item_type, :in => Types
  validates_presence_of :acks
  validates_presence_of :total
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def acknowledged_percent
    total > 0 ? acks.to_f / total.to_f : 0.0
  end

  def to_s
    begin alert_name = Alert.find(alert_id).to_s rescue alert_name = '-?-' end
    "#{alert_name}, #{acks.to_s} acks"
  end

  private
  def update_alert_type
    update_attribute('alert_type', alert.class.to_s)
  end
end

