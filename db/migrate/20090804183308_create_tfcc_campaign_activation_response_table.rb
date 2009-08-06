class CreateTfccCampaignActivationResponseTable < ActiveRecord::Migration
  def self.up
    create_table :tfcc_campaign_activation_response do |t|
      t.integer :alert_id
      t.integer :activation_id
      t.integer :campaign_id
      t.integer :transaction_id
      t.string :transaction_msg
      t.string :transaction_error
    end
  end

  def self.down
    drop_table :tfcc_campaign_activation_response
  end
end
